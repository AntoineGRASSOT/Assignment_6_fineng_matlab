function price = jamshidian_swaption_HW_consistent(Talpha, maturity, K, curve, a, sigma)
%JAMSHIDIAN_SWAPTION_HW_CONSISTENT
%
% European payer swaption pricing in Hull-White 1F
% using Jamshidian decomposition.
%
% This version uses node_zcb_HW to compute P(Talpha,Tj;x)
% in the Jamshidian root equation, so it is consistent with the tree pricer.

    %% Payment dates
    paymentTimes = (Talpha+1):1:maturity;
    nPayments = length(paymentTimes);

    if nPayments == 0
        price = 0;
        return;
    end

    %% Coupon weights, yearly accrual alpha = 1
    c = K * ones(nPayments, 1);
    c(end) = 1 + K;

    Tj = paymentTimes(:);

    %% Jamshidian root equation:
    % sum_j c_j P(Talpha,Tj;xStar) = 1
    f = @(x) coupon_bond_value_HW(Talpha, x, Tj, c, curve, a, sigma) - 1;

    %% Robust root search
    xGrid = linspace(-1, 1, 2001);
    fVals = arrayfun(f, xGrid);

    idx = find(fVals(1:end-1) .* fVals(2:end) <= 0, 1);

    if isempty(idx)
        error('Could not bracket Jamshidian root. Try enlarging xGrid.');
    end

    xStar = fzero(f, [xGrid(idx), xGrid(idx+1)]);

    %% Bond strikes K_j = P(Talpha,Tj;xStar)
    K_star = zeros(nPayments, 1);

    for j = 1:nPayments
        K_star(j) = node_zcb_HW(Talpha, Tj(j), xStar, curve, a, sigma);
    end

    %% Jamshidian decomposition:
    % payer swaption = put on coupon bond
    price = 0;

    for j = 1:nPayments
        bondPut = hw_zcb_put(0, Talpha, Tj(j), K_star(j), curve, a, sigma);
        price = price + c(j) * bondPut;
    end

end