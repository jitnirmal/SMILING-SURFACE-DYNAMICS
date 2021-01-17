function DataOut = Get_Yahoo_Options_Data(symbolid)
%Get_Yahoo_Options_Data get Option Chain Data from Yahoo
% Get Options Chain Data from Yahoo
% DataOut = Get_Yahoo_Options_Data(symbol)
% Inputs: Symbol name as a character String
% Output:  A structure with the following fields
%       data : A 1xN cell where N is the number of Expiries available
%       ExpDates : A 1xN cell array of Expiry Dates
%       Calls  : A 1xN cell array of Call Option data for each expiry
%       Puts  : A 1xN cell array of Put Option data
%       CPHeaders : Headers for the calls and puts option data
%       Headers: Headers for the data
%       FullOptionData : A combined cell array of DataOut.data
%       Last : Last Price
% Example:
%           DataOut = Get_Yahoo_Options_Data('LVS');
% (c)tradingwithmatlab.blogspot.com
DataOut = struct;
% Construct and read the URL from Yahoo Finance Website
urlText = urlread(['http://finance.yahoo.com/q/os?s=' symbolid]);
% Try getting the Table Data from URL Text 
TableData = getTableData();
% If Empty return
if(isempty(TableData))
    return
else
    DataOut.data{1} = TableData;
end
% Get the Expiry Date for later use
DataOut.ExpDates{1} = Get_Exp_Dates();
% Get Expiry Dates that are listed in the website to construct separate
% URLS for each month
NextExpiryURL = Get_Next_Expiry_URL();
if(isempty(NextExpiryURL))
   return
end

% Now read Option Tables of each Expiry month
for ik = 1:length(NextExpiryURL)
    urlText = urlread(NextExpiryURL{ik});
    DataOut.ExpDates{ik+1} = Get_Exp_Dates();
    DataOut.data{ik+1} = getTableData();
end
% Clean Up
% Convert the strings into numbers 
f = @(x)[x(:,1) num2cell(str2double(x(:,[2:8]))) x(:,9) num2cell(str2double(x(:,10:end)))];
DataOut.data = cellfun(f,DataOut.data,'uni',false);

goodDataIdx = (~cellfun('isempty',DataOut.data));
DataOut.data = DataOut.data(goodDataIdx );
DataOut.ExpDates = DataOut.ExpDates(goodDataIdx );
% Separate the data into Calls, Puts, Headers
DataOut.Calls = cellfun(@(x) x(:,[1 8 2:7]),DataOut.data,'uni',false);
DataOut.Puts = cellfun(@(x) x(:,[9 8 10:end]),DataOut.data,'uni',false);
DataOut.CPHeaders = {'Symbol','Strike','Last','Change','Bid','Ask','Volume','Open Int'};
DataOut.Headers = {'Symbol','Last','Change','Bid','Ask','Volume','Open Int','Strike',...
    'Symbol','Last','Change','Bid','Ask','Volume','Open Int'};
DataOut.FullOptionData = [DataOut.Headers ; cat(1,DataOut.data{:})];
% Get the Last Price
DataOut.Last = str2num(urlread(['http://download.finance.yahoo.com/d/quotes.csv?s=' symbolid '&f=l1&e=.csv']));

%% Get_Next_Expiry_URL
    function NextExpiry = Get_Next_Expiry_URL()
        % Get the start and end indices and look for a particular text
        Start = regexp(urlText,'View By Expiration:','end');
        end1 = regexp(urlText,'Return to Stacked View...','start');
        
        Data = urlText(Start:end1);
        Data=Data(2:end);
        % Trim the data
        Data=strtrim(Data);
        % Split the data into new lines
        newlines = regexp(Data, '[^\n]*', 'match');
        expr = '<(\w+).*?>.*?</\1>';
        if(isempty(newlines))
            NextExpiry = {};
            return
        end
        % Get the matches of particular expression
        [tok mat] = regexp(newlines{1}, expr, 'tokens', 'match');
        id1= regexp(mat{1},'</b>','start')-1;
        month{1} = mat{1}(4:id1);
        %Month and Next Expiries
        for j = 2:length(mat)-1
            id2 = regexp(mat{j},'">','end');
            id3 = regexp(mat{j},'</a','start');
            if(isempty(id3))
                return
            end
            month{j} = mat{j}(id2+1:id3-1);
            id4 = regexp(mat{j},'"','start');
            NextExpiry{j-1} = ['http://finance.yahoo.com' mat{j}(id4(1)+1:id4(2)-1)]; %#ok<*AGROW>
            NextExpiry{j-1} = regexprep(NextExpiry{j-1},'amp;','');
        end
        
    end
%% Get_Exp_Dates

    function ExpDates = Get_Exp_Dates()
        
        id1 = regexp(urlText,'Options Expiring','end');
        id2 = regexp((urlText(id1+1:id1+51)),'</b>','start');
        ExpDates = strtrim(urlText(id1+1:id1+1+id2-2));
        ExpDates=datestr(datenum(ExpDates,'dddd, mmmm dd,yyyy'));
    end

%% getTableData
    function out = getTableData()
        Main_Pattern = '.*?</table><table[^>]*>(.*?)</table';
        Tables = regexp(urlText, Main_Pattern, 'tokens');
        out = {};
        if(isempty(Tables))
            return
        end
        try
        for TableIdx = 1 : length(Tables)
            
            %Establish a row index
            rowind = 0;
            
            
            % Build cell aray of table data
            
                rows = regexpi(Tables{TableIdx}{:}, '<tr.*?>(.*?)</tr>', 'tokens');
                for rowsIdx = 1:numel(rows)
                    colind = 0;
                    if (isempty(regexprep(rows{rowsIdx}{1}, '<.*?>', '')))
                        continue
                    else
                        rowind = rowind + 1;
                    end
                    
                    headers = regexpi(rows{rowsIdx}{1}, '<th.*?>(.*?)</th>', 'tokens');
                    if ~isempty(headers)
                        for headersIdx = 1:numel(headers)
                            colind = colind + 1;
                            data = regexprep(headers{headersIdx}{1}, '<.*?>', '');
                            if (~strcmpi(data,'&nbsp;'))
                                out{rowind,colind} = strtrim(data);
                            end
                        end
                        continue
                    end
                    cols = regexpi(rows{rowsIdx}{1}, '<td.*?>(.*?)</td>', 'tokens');
                    for colsIdx = 1:numel(cols)
                        if(rowind==1)
                            if(isempty(cols{colsIdx}{1}))
                                continue
                            else
                                colind = colind + 1;
                            end
                        else
                            colind = colsIdx;
                        end
                        % The following code is required to get the sign
                        % of the change in Bid ask prices
                        data = regexprep(cols{colsIdx}{1}, '&nbsp;', ' ');
                        down=false;
                        % If Down is found then it is negative
                        if(~isempty(regexp(data,'"Down"', 'once')))
                            down=true;
                        end
                        data = regexprep(data, '<.*?>', '');
                        if(down)
                            data = ['-' strtrim(data)];
                        end
                        if (~isempty(data))
                            out{rowind,colind} = strtrim(data) ;
                        end
                    end % colsIdx
                end
                
                
        end
        out = out(3:end,:);
        catch %M  %#ok<CTCH> This depends on which version of matlab you are using
               %M.stack
        end
    end
end
