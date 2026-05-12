function P0T = market_discount_HW(curve, T)
%MARKET_DISCOUNT_HW Interpolate market discount factor P(0,T).
%
% Input:
%   curve : struct from load_HW_curve_data()
%   T     : maturity in years from settlement date
%
% Output:
%   P0T   : market discount factor at time T

    P0T = interp1(curve.times, curve.discounts, T, 'linear', 'extrap');
end