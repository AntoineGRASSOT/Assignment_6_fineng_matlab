function [X, PV_A, PV_B, Q] = price_upfront_NIG(coupon_1y, coupon_2y, sigma_NIG, kappa_NIG, eta_NIG, spread, useful_data)

% PRICE_UPFRONT_NIG  Prices the upfront X% using the NIG model

% NIG probabilities via Gil-Pelaez
Q.below   = NIG_cdf(useful_data.d_log, sigma_NIG, ...
    kappa_NIG, eta_NIG, useful_data.T1);
Q.survive = 1 - Q.below;
% PV_A — floating leg
PV_A = compute_PV_A(useful_data, spread, Q.survive);
% PV_B — structured coupon leg
PV_B = compute_PV_B(useful_data, coupon_1y, coupon_2y, ...
    Q.below, Q.survive);
X = PV_A - PV_B;

end