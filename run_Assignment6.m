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


%% Ex2 - Bermudian Swaption Pricing via Hull-White

% Hull-White parameters
a = 0.11;
sigma = 0.008;

% Product parameters
K = 0.05;
maturity = 10;
Notional_Ex2 = 100e6;
exerciseTimes = 2:9;   % non-call 2, yearly exercise dates

% Build curve structure for Hull-White functions
curve.settlement = datesSet.settlement;
curve.dates = [datesSet.settlement; dates];
curve.discounts = [1; discounts];
curve.zRates = [0; zRates];
curve.times = [0; T_curve];

fprintf('\n=========================================\n');
fprintf('Exercise 2 — Bermudian Swaption Pricing via Hull-White\n');
fprintf('=========================================\n\n');

%% QUESTION a - Bermudian Swaption Pricing by Hull-White Tree

fprintf('\n--- Question a: Bermudian Swaption Tree Pricing ---\n');

% Tree precision
T_HW = 10;
stepsPerYear = 10;
dt = 1 / stepsPerYear;
N = round(T_HW / dt);

% Build zero-mean OU trinomial tree
tree = build_OU_tree(a, sigma, dt, N);

fprintf('Zero-mean OU trinomial tree constructed.\n');
fprintf('a = %.4f\n', a);
fprintf('sigma = %.4f\n', sigma);
fprintf('dt = %.6f\n', dt);
fprintf('N = %d\n', N);
fprintf('sigmaHat = %.8f\n', tree.sigmaHat);
fprintf('dx = %.8f\n', tree.dx);
fprintf('lMax = %d\n\n', tree.lMax);

% Optional sanity check: transition probabilities
test_l_values = [-tree.lMax, -2, 0, 2, tree.lMax];

fprintf('Transition probability check:\n');

for kk = 1:length(test_l_values)
    l = test_l_values(kk);
    [next_l, p, branchType] = get_transition_HW(l, tree.lMax, tree.muHat);

    fprintf('l = %+d, branch = %s -> next states [%+d %+d %+d], probs [%.6f %.6f %.6f], sum = %.6f\n', ...
        l, branchType, next_l(1), next_l(2), next_l(3), ...
        p(1), p(2), p(3), sum(p));
end

% Market curve reproduction check
P_market_10y = market_discount_HW(curve, 10.0);
P_model_10y = node_zcb_HW(0.0, 10.0, 0.0, curve, a, sigma);

fprintf('\nMarket curve reproduction check:\n');
fprintf('Market P(0,10) = %.8f\n', P_market_10y);
fprintf('Model  P(0,10) = %.8f\n', P_model_10y);
fprintf('Difference     = %.2e\n', abs(P_market_10y - P_model_10y));

% Payer swap value sanity check
t_ex = 2.0;
x_node = 0.0;

swapValue = payer_swap_value_HW(t_ex, x_node, maturity, K, curve, a, sigma);
exerciseValue = max(swapValue, 0);
parRate = par_swap_rate_HW(t_ex, x_node, maturity, curve, a, sigma);

fprintf('\nPayer swap value test:\n');
fprintf('Payer swap value at t = %.2f, x = %.4f: %.8f\n', ...
    t_ex, x_node, swapValue);
fprintf('Exercise value max(swap,0): %.8f\n', exerciseValue);
fprintf('Par swap rate at t = %.2f, x = %.4f: %.4f%%\n', ...
    t_ex, x_node, 100 * parRate);
fprintf('Strike K: %.4f%%\n', 100 * K);

% Bermudian price
bermPrice = price_bermudian_HW_tree(tree, curve, K, maturity, exerciseTimes, a, sigma);
bermPriceEUR = bermPrice * Notional_Ex2;

fprintf('\nBermudian payer swaption pricing:\n');
fprintf('Price per unit notional: %.8f\n', bermPrice);
fprintf('Price in %% of notional: %.4f%%\n', 100 * bermPrice);
fprintf('Price in bps: %.4f bps\n', 10000 * bermPrice);
fprintf('Price in EUR: %.2f EUR\n', bermPriceEUR);
fprintf('Price in MIO EUR: %.6f MIO EUR\n', bermPriceEUR / 1e6);

%% QUESTION b - Tree Validation

fprintf('\n--- Question b: Tree Validation ---\n');

% Convergence test
fprintf('\nConvergence test:\n');

stepsList = [5, 10, 20, 40];
prices = zeros(length(stepsList), 1);

for s = 1:length(stepsList)

    stepsPerYear_test = stepsList(s);
    dt_test = 1 / stepsPerYear_test;
    N_test = round(T_HW / dt_test);

    tree_test = build_OU_tree(a, sigma, dt_test, N_test);

    prices(s) = price_bermudian_HW_tree( ...
        tree_test, curve, K, maturity, exerciseTimes, a, sigma);

    fprintf('stepsPerYear = %2d, price = %.8f, price %% = %.4f%%, price = %.2f EUR\n', ...
        stepsPerYear_test, prices(s), 100 * prices(s), prices(s) * Notional_Ex2);
end

% European-style prices by tree, used as lower/upper bound sanity check
fprintf('\nTree-based European-style prices over all exercise dates:\n');

euroPricesTree = zeros(length(exerciseTimes), 1);

for j = 1:length(exerciseTimes)
    euroPricesTree(j) = price_bermudian_HW_tree( ...
        tree, curve, K, maturity, exerciseTimes(j), a, sigma);

    fprintf('Exercise at %.0fy: European-style price = %.8f, price %% = %.4f%%, price = %.4f bps\n', ...
        exerciseTimes(j), euroPricesTree(j), 100 * euroPricesTree(j), 10000 * euroPricesTree(j));
end

lowerBoundTree = max(euroPricesTree);
upperBoundTree = sum(euroPricesTree);

fprintf('\nTree lower bound = max European-style prices = %.8f\n', lowerBoundTree);
fprintf('Bermudian price = %.8f\n', bermPrice);
fprintf('Tree upper bound = sum European-style prices = %.8f\n', upperBoundTree);

fprintf('\nCheck tree lower bound <= Bermudian <= upper bound:\n');
fprintf('Lower bound <= Bermudian: %d\n', lowerBoundTree <= bermPrice);
fprintf('Bermudian <= Upper bound: %d\n', bermPrice <= upperBoundTree);

%% QUESTION c - Bermudan bounds via Jamshidian

fprintf('\n--- Question c: Bermudan Bounds via Jamshidian ---\n');

% Use the consistent Jamshidian implementation, where the root equation
% is solved using the same node_zcb_HW formula as in the Bermudian tree.
[lowerBoundJ, upperBoundJ, europeanPricesJ] = bermudan_bounds_HW_consistent( ...
    exerciseTimes, maturity, K, curve, a, sigma);

fprintf('\n=========================================\n');
fprintf('European Swaption Prices (Jamshidian)\n');
fprintf('=========================================\n\n');

for i = 1:length(exerciseTimes)

    Talpha = exerciseTimes(i);
    priceBps = europeanPricesJ(i) * 1e4;

    fprintf('Exercise at T_alpha = %2dY : %10.4f bps, price %% = %.4f%%, price EUR = %.2f\n', ...
        Talpha, priceBps, 100 * europeanPricesJ(i), europeanPricesJ(i) * Notional_Ex2);

end

fprintf('\n=========================================\n');
fprintf('Bermudan Bounds by Jamshidian\n');
fprintf('=========================================\n\n');

fprintf('Lower Bound : %10.4f bps, %.4f%%, %.2f EUR\n', ...
    lowerBoundJ * 1e4, lowerBoundJ * 100, lowerBoundJ * Notional_Ex2);

fprintf('Upper Bound : %10.4f bps, %.4f%%, %.2f EUR\n', ...
    upperBoundJ * 1e4, upperBoundJ * 100, upperBoundJ * Notional_Ex2);

fprintf('\nBermudian tree price: %.4f bps, %.4f%%, %.2f EUR\n', ...
    bermPrice * 1e4, bermPrice * 100, bermPrice * Notional_Ex2);

fprintf('\nCheck Jamshidian lower bound <= Bermudian <= upper bound:\n');
fprintf('Lower bound <= Bermudian: %d\n', lowerBoundJ <= bermPrice);
fprintf('Bermudian <= Upper bound: %d\n', bermPrice <= upperBoundJ);
fprintf('\n');

