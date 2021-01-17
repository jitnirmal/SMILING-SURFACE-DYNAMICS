function  [surfObject] = loadSurface(persFile,optionChain)
%file='SPZX';
disp('loading option chain data');
if(exist(persFile)~=0)
    surfObject=load(persFile);
    return;
end

optionChain(:,7)=optionChain(:,1)./optionChain(:,2);

% Filter unwanted records
ex1=find(optionChain(:,4)>1);
ex2=find(optionChain(:,7)>1 & optionChain(:,6)>0);
ex3=find(optionChain(:,7)<1 & optionChain(:,6)<1);
ex4=find(optionChain(:,9)<10);
ex=[ex1;ex2;ex3;;ex4];
optionChain(ex,:)=[];
    
disp('IV computation pre regression..');
ivo=impliedVol(optionChain,0);
disp('vol surface smoothing using non parameteric regression');
[MON,MAT,IV] = npregression(optionChain,ivo.fimpliedVol,0);
disp('IV computation post regression with filters');
fivo=impliedVol(optionChain,1);
surfObject = struct('fMon',MON,'fMat',MAT,'fIV',IV,'fIVf',fivo);
save(persFile, '-struct', 'surfObject');


end