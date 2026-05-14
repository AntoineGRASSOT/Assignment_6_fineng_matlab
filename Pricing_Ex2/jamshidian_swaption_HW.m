function price = jamshidian_swaption_HW(Talpha,maturity,K,curve,a,sigma)
%JAMSHIDIAN_SWAPTION_HW
%
% European payer swaption pricing in Hull-White 1F
% using Jamshidian decomposition.
%
% INPUTS
% -------
% Talpha   : exercise time
% maturity : swap maturity
% K        : fixed strike
% curve    : market curve structure
% a        : HW mean reversion
% sigma    : HW volatility
%
% OUTPUT
% -------
% price    : European payer swaption price

    paymentTimes = (Talpha+1):1:maturity;

    nPayments = length(paymentTimes);

    if nPayments == 0
        price = 0;
        return;
    end

    %% Coupon weights

    c = K * ones(nPayments,1);

    c(end) = 1 + K;

    %% Bond maturities

    Tj = paymentTimes(:);

    %% Market discount factors

    B0_alpha = market_discount_HW(curve, Talpha);

    B0_j = zeros(nPayments,1);

    for j = 1:nPayments
        B0_j(j) = market_discount_HW(curve, Tj(j));
    end

    %% Hull-White coefficients

    tau = Tj - Talpha;

    B_HW = (1 - exp(-a * tau)) / a;

    Vj = (sigma / a)^2 * (tau - 2 * (1 - exp(-a * tau)) / a + (1 - exp(-2 * a * tau)) / (2 * a));

    %% Jamshidian equation

    ratio_j = B0_j ./ B0_alpha;

    f = @(x) sum(c .* ratio_j .* exp(-x .* B_HW - 0.5 .* Vj)) - 1;

    xStar = fzero(f, [-1,1]);

    %% Bond strikes

    K_star = ratio_j .* exp(-xStar .* B_HW - 0.5 .* Vj);

    %% Jamshidian decomposition

    price = 0;

    for j = 1:nPayments

        bondPut = hw_zcb_put(0, Talpha, Tj(j), K_star(j), curve, a, sigma);

        price = price + c(j) * bondPut;

    end

end