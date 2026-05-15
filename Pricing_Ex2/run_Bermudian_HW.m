clear; clc;

%% Add required paths
thisFile = mfilename('fullpath');
thisDir = fileparts(thisFile);          % Pricing_Ex2 folder
projectRoot = fileparts(thisDir);       % Assignment_6_fineng_matlab folder

addpath(thisDir);
addpath(fullfile(projectRoot, 'utilities'));

fprintf('Running Bermudian Swaption Pricing via Hull-White...\n\n');

%% Hull-White parameters from assignment
a = 0.11;          % mean reversion speed
sigma = 0.008;    % volatility

%% Product parameters
notional = 100e6;         % 100 MIO EUR
K = 0.05;                 % strike 5%
maturity = 10.0;          % final swap maturity, in years
exerciseTimes = 2:1:9;    % non-call 2, yearly exercise dates

%% Product horizon
T = 10;                   % 10-year Bermudian swaption horizon

%% Tree precision
stepsPerYear = 10;
dt = 1 / stepsPerYear;
N = round(T / dt);

%% Build zero-mean OU trinomial tree
tree = build_OU_tree(a, sigma, dt, N);

%% Print basic tree information
fprintf('===== POINT (a) - Bermudian tree =====\n');
fprintf('Zero-mean OU trinomial tree constructed.\n');
fprintf('a = %.4f\n', a);
fprintf('sigma = %.4f\n', sigma);
fprintf('dt = %.6f\n', dt);
fprintf('N = %d\n', N);
fprintf('sigmaHat = %.8f\n', tree.sigmaHat);
fprintf('dx = %.8f\n', tree.dx);
fprintf('lMax = %d\n\n', tree.lMax);

%% Test transition probabilities
test_l_values = [-tree.lMax, -2, 0, 2, tree.lMax];

fprintf('Transition probability check:\n');

for k = 1:length(test_l_values)
    l = test_l_values(k);
    [next_l, p, branchType] = get_transition_HW(l, tree.lMax, tree.muHat);

    fprintf('l = %+d, branch = %s -> next states [%+d %+d %+d], probs [%.6f %.6f %.6f], sum = %.6f\n', ...
        l, branchType, next_l(1), next_l(2), next_l(3), ...
        p(1), p(2), p(3), sum(p));
end

%% Load market discount curve
curve = load_HW_curve_data();

%% Test node zero-coupon bond price
fprintf('\nNode zero-coupon bond price test:\n');

t_test = 2.0;
T_test = 10.0;
x_test = 0.0;

P_node = node_zcb_HW(t_test, T_test, x_test, curve, a, sigma);

fprintf('P(t=%.2f, T=%.2f, x=%.4f) = %.8f\n', ...
    t_test, T_test, x_test, P_node);

%% Check market curve reproduction at t = 0
P_market_10y = market_discount_HW(curve, 10.0);
P_node_10y = node_zcb_HW(0.0, 10.0, 0.0, curve, a, sigma);

fprintf('\nMarket curve reproduction check:\n');
fprintf('Market P(0,10) = %.8f\n', P_market_10y);
fprintf('Model  P(0,10) = %.8f\n', P_node_10y);
fprintf('Difference     = %.2e\n', abs(P_market_10y - P_node_10y));

%% Test payer swap value
fprintf('\nPayer swap value test:\n');

t_ex = 2.0;
x_node = 0.0;

swapValue = payer_swap_value_HW(t_ex, x_node, maturity, K, curve, a, sigma);
exerciseValue = max(swapValue, 0);

fprintf('Payer swap value at t = %.2f, x = %.4f: %.8f\n', ...
    t_ex, x_node, swapValue);
fprintf('Exercise value max(swap,0): %.8f\n', exerciseValue);

parRate = par_swap_rate_HW(t_ex, x_node, maturity, curve, a, sigma);

fprintf('Par swap rate at t = %.2f, x = %.4f: %.4f%%\n', ...
    t_ex, x_node, 100 * parRate);
fprintf('Strike K: %.4f%%\n', 100 * K);

%% Price Bermudian payer swaption
fprintf('\nBermudian payer swaption pricing:\n');

bermPrice = price_bermudian_HW_tree(tree, curve, K, maturity, exerciseTimes, a, sigma);
bermPriceEUR = bermPrice * notional;

fprintf('Bermudian payer swaption price per unit notional: %.8f\n', bermPrice);
fprintf('Bermudian payer swaption price in %% of notional: %.4f%%\n', 100 * bermPrice);
fprintf('Bermudian payer swaption price in bps: %.4f bps\n', 10000 * bermPrice);
fprintf('Bermudian payer swaption price in EUR: %.2f\n', bermPriceEUR);
fprintf('Bermudian payer swaption price in MIO EUR: %.6f\n', bermPriceEUR / 1e6);

%% Convergence test
fprintf('\n===== POINT (b) - Tree validation =====\n');
fprintf('\nConvergence test:\n');

stepsList = [5, 10, 20, 40];
prices = zeros(length(stepsList), 1);

for s = 1:length(stepsList)

    stepsPerYear_test = stepsList(s);
    dt_test = 1 / stepsPerYear_test;
    N_test = round(T / dt_test);

    tree_test = build_OU_tree(a, sigma, dt_test, N_test);

    prices(s) = price_bermudian_HW_tree( ...
        tree_test, curve, K, maturity, exerciseTimes, a, sigma);

    fprintf('stepsPerYear = %2d, price = %.8f, price %% = %.4f%%, price = %.2f EUR\n', ...
        stepsPerYear_test, prices(s), 100 * prices(s), prices(s) * notional);
end

%% Simple European-style lower bound check
fprintf('\nEuropean lower bound check using final exercise date:\n');

europeanExerciseTime = 9;
euroPrice9y = price_bermudian_HW_tree(tree, curve, K, maturity, europeanExerciseTime, a, sigma);

fprintf('European-style payer swaption price, exercise at 9y: %.8f\n', euroPrice9y);
fprintf('European-style payer swaption price at 9y in bps: %.4f bps\n', 10000 * euroPrice9y);
fprintf('Bermudian payer swaption price: %.8f\n', bermPrice);
fprintf('Difference Bermudian - European 9y: %.8f\n', bermPrice - euroPrice9y);

%% Tree-based European-style bounds over all exercise dates
fprintf('\nTree-based European bounds over all exercise dates:\n');

euroExerciseTimes = exerciseTimes;
euroPrices = zeros(length(euroExerciseTimes), 1);

for j = 1:length(euroExerciseTimes)
    euroPrices(j) = price_bermudian_HW_tree( ...
        tree, curve, K, maturity, euroExerciseTimes(j), a, sigma);

    fprintf('Exercise at %.0fy: European-style price = %.8f, price %% = %.4f%%, price = %.4f bps\n', ...
        euroExerciseTimes(j), euroPrices(j), 100 * euroPrices(j), 10000 * euroPrices(j));
end

lowerBoundTree = max(euroPrices);
upperBoundTree = sum(euroPrices);

fprintf('\nTree lower bound = max European-style prices = %.8f\n', lowerBoundTree);
fprintf('Bermudian price = %.8f\n', bermPrice);
fprintf('Tree upper bound = sum European-style prices = %.8f\n', upperBoundTree);

fprintf('\nCheck tree lower bound <= Bermudian <= upper bound:\n');
fprintf('Lower bound <= Bermudian: %d\n', lowerBoundTree <= bermPrice);
fprintf('Bermudian <= Upper bound: %d\n', bermPrice <= upperBoundTree);

%% ===== POINT (c) - Jamshidian bounds using our node ZCB formula =====
fprintf('\n===== POINT (c) - Jamshidian bounds =====\n');

% We use the consistent Jamshidian implementation, where the root equation
% is solved using the same node_zcb_HW formula as in the Bermudian tree.
[lowerBoundJ, upperBoundJ, euroPricesJ] = bermudan_bounds_HW_consistent( ...
    exerciseTimes, maturity, K, curve, a, sigma);

fprintf('Per-date European prices by Jamshidian decomposition:\n');

for i = 1:length(exerciseTimes)
    fprintf('T_alpha = %.0fy : %.4f bps, price %% = %.4f%%, price EUR = %.2f\n', ...
        exerciseTimes(i), ...
        10000 * euroPricesJ(i), ...
        100 * euroPricesJ(i), ...
        euroPricesJ(i) * notional);
end

fprintf('\nJamshidian lower bound (max European) : %.4f bps, price %% = %.4f%%\n', ...
    10000 * lowerBoundJ, 100 * lowerBoundJ);
fprintf('Jamshidian lower bound in EUR         : %.2f\n', lowerBoundJ * notional);
fprintf('Jamshidian lower bound in MIO EUR     : %.6f\n', lowerBoundJ * notional / 1e6);

fprintf('\nJamshidian upper bound (sum Europeans): %.4f bps, price %% = %.4f%%\n', ...
    10000 * upperBoundJ, 100 * upperBoundJ);
fprintf('Jamshidian upper bound in EUR         : %.2f\n', upperBoundJ * notional);
fprintf('Jamshidian upper bound in MIO EUR     : %.6f\n', upperBoundJ * notional / 1e6);

fprintf('\nBermudian tree price                  : %.4f bps, price %% = %.4f%%\n', ...
    10000 * bermPrice, 100 * bermPrice);
fprintf('Bermudian tree price in EUR           : %.2f\n', bermPrice * notional);
fprintf('Bermudian tree price in MIO EUR       : %.6f\n', bermPrice * notional / 1e6);

fprintf('\nCheck Jamshidian lower bound <= Bermudian <= upper bound:\n');
fprintf('Lower bound <= Bermudian: %d\n', lowerBoundJ <= bermPrice);
fprintf('Bermudian <= Upper bound: %d\n', bermPrice <= upperBoundJ);

%% Optional plots
% Uncomment these lines if the plotting functions are available.
% plot_zero_curve_HW(curve);
% plot_convergence_HW(stepsList, prices);
% plot_european_prices_HW(exerciseTimes, euroPricesJ);
% plot_bounds_HW(lowerBoundJ, bermPrice, upperBoundJ);