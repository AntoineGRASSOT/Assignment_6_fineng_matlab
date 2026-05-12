function curve = load_HW_curve_data()
%LOAD_HW_CURVE_DATA Load and bootstrap the interest rate curve for HW pricing.
%
% Output:
%   curve.settlement   settlement / valuation date
%   curve.dates        bootstrapped curve dates
%   curve.discounts    market discount factors
%   curve.zRates       zero rates

    %% Locate market data file
    dataFile = fullfile('..', 'data', 'MktData_CurveBootstrap.xls');

    if ~isfile(dataFile)
        dataFile = fullfile('..', 'data', 'MktData_CurveBootstrap.xlsx');
    end

    if ~isfile(dataFile)
        error('Curve bootstrap data file not found. Please check the file name in the data folder.');
    end

    %% Read market data
    % The second argument is required by your readExcelData function.
    % In many previous assignments, formatData = true is used for Excel market data.
    formatData = true;

    [datesSet, ratesSet] = readExcelData(dataFile, formatData);

  %% Bootstrap discount curve
[dates, discounts, zRates] = bootstrap(datesSet, ratesSet);

%% Add settlement date back
% The bootstrap function removes the settlement date at the end.
% For Hull-White pricing, we need P(0,0)=1.
settlement = datesSet.settlement;

dates = [settlement; dates];
discounts = [1; discounts];
zRates = [0; zRates];

%% Store curve
curve.settlement = settlement;
curve.dates = dates;
curve.discounts = discounts;
curve.zRates = zRates;

%% Time grid in years, ACT/365
curve.times = yearfrac(curve.settlement, curve.dates, 3);
 


    %% Basic output
    fprintf('\nMarket curve loaded successfully.\n');
    fprintf('Settlement date: %s\n', datestr(curve.settlement));
    fprintf('Number of curve dates: %d\n', length(curve.dates));
    fprintf('First discount: %.8f\n', curve.discounts(1));
    fprintf('Last curve date: %s\n', datestr(curve.dates(end)));
    fprintf('Last discount: %.8f\n\n', curve.discounts(end));

end