function price = price_bermudian_HW_tree(tree, curve, K, maturity, exerciseTimes, a, sigma)
%PRICE_BERMUDIAN_HW_TREE Price Bermudian payer swaption by HW trinomial tree.
%
% Inputs:
%   tree          zero-mean OU trinomial tree
%   curve         market curve struct
%   K             fixed strike rate
%   maturity      final maturity of the underlying swap
%   exerciseTimes exercise dates in years, e.g. 2:1:9
%   a             Hull-White mean reversion
%   sigma         Hull-White volatility
%
% Output:
%   price         Bermudian payer swaption price per unit notional

    dt = tree.dt;
    N = tree.N;
    lMax = tree.lMax;
    dx = tree.dx;
    muHat = tree.muHat;

    lGrid = (-lMax:lMax)';
    nStates = length(lGrid);

    %% Terminal option values
    Vnext = zeros(nStates, 1);

    %% Backward induction from final time step to time 0
    for i = N-1:-1:0

        t = i * dt;
        tNext = (i+1) * dt;

        Vcurr = zeros(nStates, 1);

        for idx = 1:nStates

            l = lGrid(idx);
            x = l * dx;

            %% Continuation value
            [next_l, p, ~] = get_transition_HW(l, lMax, muHat);

            expectedValue = 0;

            for k = 1:3
                l_child = next_l(k);
                child_idx = l_child + lMax + 1;

                expectedValue = expectedValue + p(k) * Vnext(child_idx);
            end

            %% One-step node discount P(t,t+dt)
            disc = node_zcb_HW(t, tNext, x, curve, a, sigma);

            continuationValue = disc * expectedValue;

            %% Exercise value if t is an exercise date
            if ismembertol(t, exerciseTimes, 1e-10)
                swapValue = payer_swap_value_HW(t, x, maturity, K, curve, a, sigma);
                exerciseValue = max(swapValue, 0);

                Vcurr(idx) = max(exerciseValue, continuationValue);
            else
                Vcurr(idx) = continuationValue;
            end
        end

        Vnext = Vcurr;
    end

    %% Initial state is x = 0, i.e. l = 0
    idx0 = lMax + 1;
    price = Vnext(idx0);
end