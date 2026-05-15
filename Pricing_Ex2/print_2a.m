function print_2a(a, sigma, dt, N, tree, P_market_10y, P_model_10y, t_ex, x_node, swapValue, parRate, K, bermPrice, Notional)
    fprintf('\n=========================================\n');
    fprintf('Exercise 2 — Bermudian Swaption Pricing via Hull-White\n');
    fprintf('=========================================\n\n');
    fprintf('--- Question a: Bermudian Swaption Tree Pricing ---\n');
    fprintf('Zero-mean OU trinomial tree constructed.\n');
    fprintf('a = %.4f\n', a);
    fprintf('sigma = %.4f\n', sigma);
    fprintf('dt = %.6f\n', dt);
    fprintf('N = %d\n', N);
    fprintf('sigmaHat = %.8f\n', tree.sigmaHat);
    fprintf('dx = %.8f\n', tree.dx);
    fprintf('lMax = %d\n\n', tree.lMax);

    % Sanity check: transition probabilities
    test_l_values = [-tree.lMax, -2, 0, 2, tree.lMax];
    fprintf('Transition probability check:\n');
    for kk = 1:length(test_l_values)
        l = test_l_values(kk);
        [next_l, p, branchType] = get_transition_HW(l, tree.lMax, tree.muHat);
        fprintf('l = %+d, branch = %s -> next states [%+d %+d %+d], probs [%.6f %.6f %.6f], sum = %.6f\n', ...
            l, branchType, next_l(1), next_l(2), next_l(3), p(1), p(2), p(3), sum(p));
    end

    fprintf('\nMarket curve reproduction check:\n');
    fprintf('Market P(0,10) = %.8f\n', P_market_10y);
    fprintf('Model  P(0,10) = %.8f\n', P_model_10y);
    fprintf('Difference     = %.2e\n', abs(P_market_10y - P_model_10y));

    fprintf('\nPayer swap value test:\n');
    fprintf('Payer swap value at t = %.2f, x = %.4f: %.8f\n', t_ex, x_node, swapValue);
    fprintf('Exercise value max(swap,0): %.8f\n', max(swapValue, 0));
    fprintf('Par swap rate at t = %.2f, x = %.4f: %.4f%%\n', t_ex, x_node, 100 * parRate);
    fprintf('Strike K: %.4f%%\n', 100 * K);

    bermPriceEUR = bermPrice * Notional;
    fprintf('\nBermudian payer swaption pricing:\n');
    fprintf('Price per unit notional: %.8f\n', bermPrice);
    fprintf('Price in %% of notional: %.4f%%\n', 100 * bermPrice);
    fprintf('Price in bps: %.4f bps\n', 10000 * bermPrice);
    fprintf('Price in EUR: %.2f EUR\n', bermPriceEUR);
    fprintf('Price in MIO EUR: %.6f MIO EUR\n', bermPriceEUR / 1e6);
end