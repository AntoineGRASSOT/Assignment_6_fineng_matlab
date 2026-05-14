clear; clc;

%% Add required paths
thisFile = mfilename('fullpath');
thisDir = fileparts(thisFile);          % Pricing_Ex2 folder
projectRoot = fileparts(thisDir);       % Assignment_6_fineng_matlab folder

addpath(thisDir);
addpath(fullfile(projectRoot, 'utilities'));

fprintf('Running Bermudian Swaption Pricing via Hull-White...\n\n');
addpath('../utilities')

%% Hull-White parameters from assignment
a = 0.11;          % mean reversion speed
sigma = 0.008;    % volatility

%% Product horizon
T = 10;            % 10-year Bermudian swaption horizon

%% Tree precision
stepsPerYear = 10;
dt = 1 / stepsPerYear;
N = round(T / dt);

%% Build zero-mean OU trinomial tree
tree = build_OU_tree(a, sigma, dt, N);

%% Print basic information
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
fprintf('Node zero-coupon bond price test:\n');

t_test = 2.0;
T_test = 10.0;
x_test = 0.0;

P_node = node_zcb_HW(t_test, T_test, x_test, curve, a, sigma);

fprintf('P(t=%.2f, T=%.2f, x=%.4f) = %.8f\n', ...
    t_test, T_test, x_test, P_node);

%% Check reproduction at t = 0
P_market_10y = market_discount_HW(curve, 10.0);
P_node_10y = node_zcb_HW(0.0, 10.0, 0.0, curve, a, sigma);

fprintf('\nMarket curve reproduction check:\n');
fprintf('Market P(0,10) = %.8f\n', P_market_10y);
fprintf('Model  P(0,10) = %.8f\n', P_node_10y);
fprintf('Difference     = %.2e\n', abs(P_market_10y - P_node_10y));

%% %% Test payer swap value
fprintf('\nPayer swap value test:\n');

K = 0.05;
maturity = 10.0;

t_ex = 2.0;
x_node = 0.0;

swapValue = payer_swap_value_HW(t_ex, x_node, maturity, K, curve, a, sigma);
exerciseValue = max(swapValue, 0);

fprintf('Payer swap value at t = %.2f, x = %.4f: %.8f\n', ...
    t_ex, x_node, swapValue);
fprintf('Exercise value max(swap,0): %.8f\n', exerciseValue);

parRate = par_swap_rate_HW(t_ex, x_node, maturity, curve, a, sigma);

fprintf('Par swap rate at t = %.2f, x = %.4f: %.4f%%\n', ...
    t_ex, x_node, 100*parRate);
fprintf('Strike K: %.4f%%\n', 100*K);


%% Price Bermudian payer swaption
fprintf('\nBermudian payer swaption pricing:\n');

K = 0.05;
maturity = 10.0;
exerciseTimes = 2:1:9;   % non-call 2, yearly exercise dates

bermPrice = price_bermudian_HW_tree(tree, curve, K, maturity, exerciseTimes, a, sigma);

fprintf('Bermudian payer swaption price per unit notional: %.8f\n', bermPrice);
fprintf('Bermudian payer swaption price in %% of notional: %.4f%%\n', 100 * bermPrice);


%% Convergence test
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

    fprintf('stepsPerYear = %2d, price = %.8f, price %% = %.4f%%\n', ...
        stepsPerYear_test, prices(s), 100 * prices(s));
end

%% European-style lower bound check
fprintf('\nEuropean lower bound check:\n');

europeanExerciseTime = 9;
euroPrice9y = price_bermudian_HW_tree(tree, curve, K, maturity, europeanExerciseTime, a, sigma);

fprintf('European-style payer swaption price, exercise at 9y: %.8f\n', euroPrice9y);
fprintf('Bermudian payer swaption price: %.8f\n', bermPrice);
fprintf('Difference Bermudian - European: %.8f\n', bermPrice - euroPrice9y);

%% Upper bound: sum of European-style swaptions over all exercise dates
fprintf('\nEuropean upper bound over all exercise dates:\n');

euroExerciseTimes = exerciseTimes;
euroPrices = zeros(length(euroExerciseTimes), 1);

for j = 1:length(euroExerciseTimes)
    euroPrices(j) = price_bermudian_HW_tree( ...
        tree, curve, K, maturity, euroExerciseTimes(j), a, sigma);

    fprintf('Exercise at %.0fy: European-style price = %.8f, price %% = %.4f%%\n', ...
        euroExerciseTimes(j), euroPrices(j), 100 * euroPrices(j));
end

lowerBound = max(euroPrices);
upperBound = sum(euroPrices);

fprintf('\nLower bound = max European-style prices = %.8f\n', lowerBound);
fprintf('Bermudian price = %.8f\n', bermPrice);
fprintf('Upper bound = sum European-style prices = %.8f\n', upperBound);

fprintf('\nCheck lower bound <= Bermudian <= upper bound:\n');
fprintf('Lower bound <= Bermudian: %d\n', lowerBound <= bermPrice);
fprintf('Bermudian <= Upper bound: %d\n', bermPrice <= upperBound);