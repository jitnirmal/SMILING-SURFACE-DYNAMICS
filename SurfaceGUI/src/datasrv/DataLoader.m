function[optionData]=DataLoader(dbFile)
disp('loading option chain data');
optionData=xlsread(strcat('..\db\',dbFile));
disp('loaded option chain data from db');
end