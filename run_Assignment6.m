%% 
clc; clear all;
addpath('data');
addpath('Pricing_Ex1');
addpath(genpath('Pricing_Ex1'));
addpath('Pricing_Ex2');
addpath('utilities');

%% Parameters
load('eurostoxx_Poli.mat')
formatDate = 'dd/mm/yyyy';
% bootstrap datas to compute zero rates
[datesSet, ratesSet] = readExcelData('MktData_CurveBootstrap.xls', formatDate);
[dates, discounts, zRates]=bootstrap(datesSet, ratesSet);
T_curve = yearfrac(datesSet.settlement, dates, 3); % ACT/365

%% Ex1
% Parameters
Notional   = 100e6;
spread     = 0.013;                    T          = 2;
start_date = datenum('19-Feb-2008');
S0         = cSelect.reference;        q          = cSelect.dividends;
coupon_1y  = 0.06;                     coupon_2y  = 0.02;
K_strike   = 3200;                     sigma_NIG  = 0.20;
kappa_NIG  = 1;                        eta_NIG    = 0.03;
useful_data = build_useful_data(start_date, T, S0, q, K_strike, dates, T_curve, zRates);

%% Point a — NIG pricing
[X_NIG, PV_A_NIG, PV_B_NIG, Q_NIG] = price_upfront_NIG(coupon_1y, coupon_2y, sigma_NIG, kappa_NIG, eta_NIG, spread, useful_data);
print_results('Point a — NIG', X_NIG, PV_A_NIG, PV_B_NIG, Q_NIG, Notional);

%% Point b — Black pricing
sigma_Black = interp1(cSelect.strikes, cSelect.surface, K_strike, 'linear');
[X_BS, PV_A_BS, PV_B_BS, Q_BS] = price_upfront_BS(K_strike, spread, coupon_1y, coupon_2y, useful_data, sigma_Black);
print_results('Point b — Black', X_BS, PV_A_BS, PV_B_BS, Q_BS, Notional);

% Comparison
print_comparison(X_NIG, X_BS, sigma_Black);

%% point d- MC pricing
% now we need the distributions of S1 and S2 jointly, we cannot use what we
T_3y = 3; rng(42);
useful_data_3y = build_useful_data(start_date, T_3y, S0, q, K_strike, dates, T_curve, zRates);
N_paths = 100000; 
coupon_early = 0.06;
coupon_final = 0.02;
[X_path, PV_A_path, PV_B_path, Q_stop1, Q_stop2, Q_survive3] = ...
    price_upfront_NIG_path(coupon_early, coupon_final, sigma_NIG, ...
                           kappa_NIG, eta_NIG, spread, useful_data_3y, N_paths);
print_results_path('Point D — 3Y Autocallable (NIG Monte Carlo)', ...
    X_path, PV_A_path, PV_B_path, Q_stop1, Q_stop2, Q_survive3, Notional);
%% Point e — Pricing Error using Black Model
sigma_Black = interp1(cSelect.strikes, cSelect.surface, K_strike, 'linear');
[X_BS, PV_A_BS, PV_B_BS] = price_upfront_BS_path(coupon_early, coupon_final, sigma_Black, spread, useful_data_3y, N_paths);
Pricing_Error_perc = (X_BS - X_path) * 100;
Pricing_Error_EUR  = (X_BS - X_path) * Notional;
fprintf('\n=== Point E — Pricing Error (Black vs NIG) ===\n');
fprintf('  Upfront X%% (NIG)   = %.4f%%\n', X_path * 100);
fprintf('  Upfront X%% (Black) = %.4f%%\n', X_BS * 100);
fprintf('  Pricing Error (%%)  = %.4f%%\n', Pricing_Error_perc);
fprintf('  Pricing Error (EUR)= %.2f EUR\n', Pricing_Error_EUR);


%% Ex2
a = 0.11;
sigma = 0.008;
K = 0.05;
maturity = 10;
curve.settlement = datesSet.settlement;
curve.dates = [datesSet.settlement; dates];
curve.discounts = [1; discounts];
curve.zRates = [0; zRates];
curve.times =  [0; T_curve];

%% QUESTION a -Run Bermudian Swaption part


%% QUESTION c - Bermudan bounds via Jamshidian
exerciseTimes = 2:9;

[lowerBound, upperBound, europeanPrices] = bermudan_bounds_HW(exerciseTimes, maturity, K, curve, a, sigma);

fprintf('\n=========================================\n');
fprintf('European Swaption Prices (Jamshidian)\n');
fprintf('=========================================\n\n');

for i = 1:length(exerciseTimes)

    Talpha = exerciseTimes(i);

    priceBps = europeanPrices(i) * 1e4;

    fprintf('Exercise at T_alpha = %2dY : %10.4f bps\n', Talpha, priceBps);

end

fprintf('\n=========================================\n');
fprintf('Bermudan Bounds\n');
fprintf('=========================================\n\n');
fprintf('Lower Bound : %10.4f bps\n', lowerBound * 1e4);
fprintf('Upper Bound : %10.4f bps\n', upperBound * 1e4);
fprintf('\n');



