function DataOut = loadDataFromYahoo(symbolid)
symbol='MSFT';
disp(' Fetching data... ');
DataOut = Get_Yahoo_Options_Data(symbol);
disp(' Data Fetched ');

data=DataOut.FullOptionData(2:end,1);
pyy = cellfun(@(x) x(end-14:end-13), data, 'UniformOutput', false);
pmm = cellfun(@(x) x(end-12:end-11), data, 'UniformOutput', false);
pdd = cellfun(@(x) x(end-10:end-9), data, 'UniformOutput', false);
pdate=strcat(pmm,'-',pdd,'-',pyy)
pds=datestr(now,'mm-dd-yy');
maturity=yearfrac(pds,datestr(datenum(pdate)));
ppdate=['expiry';pdate];


optionData
mmaturity=['maturity';num2cell(maturity)];
Strike=cell2mat(DataOut.FullOptionData(2:end,8));
CallPrice=cell2mat(DataOut.FullOptionData(2:end,2));

cell2csv(strcat(symbol,'-data.csv'),DataOut.FullOptionData);
disp(' Done...... ');
