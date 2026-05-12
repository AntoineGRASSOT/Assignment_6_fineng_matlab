function [dates, rates] = readExcelData(filename, formatData)
% Reads market data from Excel.
% All input rates are in % units.

%% Dates from Excel

% Settlement date: E8
settlementCell = readcell(filename, 'Sheet', 1, 'Range', 'E8:E8');
dates.settlement = convertExcelDates(settlementCell(1,1), formatData);

% Dates relative to deposits: D11:D18
date_depositi = readcell(filename, 'Sheet', 1, 'Range', 'D11:D18');
date_depositi = date_depositi(1:8, 1);
dates.depos = convertExcelDates(date_depositi, formatData);

% Dates relative to futures: Q12:R20
date_futures_read = readcell(filename, 'Sheet', 1, 'Range', 'Q12:R20');
date_futures_read = date_futures_read(1:9, 1:2);
dates.futures = convertExcelDates(date_futures_read, formatData);

% Dates relative to swaps: D39:D88
date_swaps = readcell(filename, 'Sheet', 1, 'Range', 'D39:D88');
date_swaps = date_swaps(1:50, 1);
dates.swaps = convertExcelDates(date_swaps, formatData);

%% Rates from Excel

% Deposits: E11:F18
tassi_depositi = readcell(filename, 'Sheet', 1, 'Range', 'E11:F18');
tassi_depositi = tassi_depositi(1:8, 1:2);
tassi_depositi = cell2mat(tassi_depositi);
rates.depos = tassi_depositi / 100;

% Futures: E28:F36
tassi_futures = readcell(filename, 'Sheet', 1, 'Range', 'E28:F36');
tassi_futures = tassi_futures(1:9, 1:2);
tassi_futures = cell2mat(tassi_futures);

% Rates from futures
tassi_futures = 100 - tassi_futures;
rates.futures = tassi_futures / 100;

% Swaps: E39:F88
tassi_swaps = readcell(filename, 'Sheet', 1, 'Range', 'E39:F88');
tassi_swaps = tassi_swaps(1:50, 1:2);
tassi_swaps = cell2mat(tassi_swaps);
rates.swaps = tassi_swaps / 100;

end


function out = convertExcelDates(x, formatData)
% Converts Excel dates into MATLAB datenum.
% Handles datetime, numeric Excel dates, char/string and missing cells.

    if iscell(x)
        out = nan(size(x));

        for k = 1:numel(x)
            value = x{k};

            if isempty(value)
                out(k) = NaN;

            elseif ismissing(value)
                out(k) = NaN;

            elseif isdatetime(value)
                out(k) = datenum(value);

            elseif isnumeric(value)
                if isscalar(value) && isnan(value)
                    out(k) = NaN;
                else
                    out(k) = value;
                end

            elseif isstring(value)
                value = strtrim(value);
                if ismissing(value) || strlength(value) == 0
                    out(k) = NaN;
                else
                    out(k) = datenum(char(value), formatData);
                end

            elseif ischar(value)
                value = strtrim(value);
                if isempty(value)
                    out(k) = NaN;
                else
                    out(k) = datenum(value, formatData);
                end

            else
                fprintf('\nUnsupported Excel date cell.\n');
                fprintf('Class: %s\n', class(value));
                disp('Value:');
                disp(value);
                error('Unsupported date type in Excel cell.');
            end
        end

    elseif isdatetime(x)
        out = datenum(x);

    elseif isnumeric(x)
        out = x;

    elseif isstring(x)
        x = strtrim(x);
        out = datenum(char(x), formatData);

    elseif ischar(x)
        x = strtrim(x);
        out = datenum(x, formatData);

    else
        fprintf('\nUnsupported Excel date input.\n');
        fprintf('Class: %s\n', class(x));
        disp('Value:');
        disp(x);
        error('Unsupported date input type.');
    end
end