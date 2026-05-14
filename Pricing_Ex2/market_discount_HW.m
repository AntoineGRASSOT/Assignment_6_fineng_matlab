function P0T = market_discount_HW(curve, T)
%MARKET_DISCOUNT_HW
%
% Interpolate zero rates linearly and reconstruct
% the market discount factor P(0,T).
%
% INPUTS
% -------
% curve : market curve structure
% T     : maturity in years
%
% OUTPUT
% -------
% P0T   : market discount factor

    if abs(T) < 1e-12
        P0T = 1.0;
        return;
    end

    %% Remove t=0 point

    validIdx = curve.times > 0;

    times = curve.times(validIdx);

    zRates = curve.zRates(validIdx);

    %% Linear interpolation of zero rates

    zT = interp1(times, zRates, T, 'linear', 'extrap');

    %% Discount factor reconstruction

    P0T = exp(-zT * T);

end