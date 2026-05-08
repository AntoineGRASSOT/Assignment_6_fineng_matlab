function [X, PV_A, PV_B, Q] = price_upfront_BS(K_strike, spread, coupon_1y, coupon_2y, useful_data, sigma_BS)

% PRICE_UPFRONT_BS  Prices the upfront X% using Black-Scholes model
%
% The payoff depends only on S1 at a single date T1 — no path dependence —
% so the marginal distribution of S1 is sufficient.
% Under BS: Q(S1 < K) = N(-d2), Q(S1 >= K) = N(d2)

T1 = useful_data.T1 ; 
d2 = (log(useful_data.F0_1y / K_strike) - 0.5*sigma_BS^2*T1) ...
    / (sigma_BS * sqrt(T1));
Q.below   = normcdf(-d2);
Q.survive = normcdf(d2);

% PV_A and PV_B use same formulas as NIG — only probabilities differ
PV_A = compute_PV_A(useful_data, spread, Q.survive);
PV_B = compute_PV_B(useful_data, coupon_1y, coupon_2y, ...
    Q.below, Q.survive);
X = PV_A - PV_B;

end