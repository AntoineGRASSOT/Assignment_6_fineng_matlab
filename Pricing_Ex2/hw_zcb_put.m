function price = hw_zcb_put(t0, ti, ti1, K, curve, a, sigma)
%HW_ZCB_PUT
%
% European put option on a zero-coupon bond
% in the Hull-White 1F model.
%
% INPUTS
% -------
% t0     : valuation time
% ti     : option maturity
% ti1    : bond maturity
% K      : strike
% curve  : market curve structure
% a      : mean reversion
% sigma  : volatility
%
% OUTPUT
% -------
% price  : put price

    if ti1 <= ti
        error('Bond maturity must be greater than option maturity.');
    end

    %% Discount factors

    B0_ti = market_discount_HW(curve, ti);
    B0_ti1 = market_discount_HW(curve, ti1);

    %% Forward bond price

    F = B0_ti1 / B0_ti;

    %% Hull-White bond volatility

    tau = ti1 - ti;

    sigmaP = (sigma / a) * (1 - exp(-a * tau)) * sqrt((1 - exp(-2 * a * (ti - t0))) / (2 * a));

    %% Black terms

    d1 = log(F / K) / sigmaP + 0.5 * sigmaP;

    d2 = d1 - sigmaP;

    %% Bond put option price

    price = K * B0_ti * normcdf(-d2) - B0_ti1 * normcdf(-d1);

end