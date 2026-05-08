function disc = discount_from_zrate(settle_date, target_date, dates, zRates)
% Interpolates zero rate at target_date, then computes discount factor
%
% INPUTS:
%   settle_date : settlement date (datenum)
%   target_date : date where we want the discount factor (datenum)
%   dates       : bootstrap dates vector
%   zRates      : bootstrap zero rates vector (ACT/365)
%
% OUTPUT:
%   disc : discount factor P(t0, target_date)

% interpolate zero rate (ACT/365)
z = interp1(dates, zRates, target_date, 'linear');

% discount factor from zero rate
t = yearfrac(settle_date, target_date, 3); % ACT/365
disc = exp(-z * t);
end