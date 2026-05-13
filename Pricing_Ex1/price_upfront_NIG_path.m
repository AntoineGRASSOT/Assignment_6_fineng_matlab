function [X, PV_A, PV_B,Q_stop1,Q_stop2,Q_survive3] = price_upfront_NIG_path(coupon_early, coupon_final, sigma_NIG, kappa_NIG, eta_NIG, spread, useful_data, N_paths)
% PRICE_UPFRONT_NIG_PATH  Prices the upfront X% using NIG Monte Carlo
    
    % 1. Run the Monte Carlo simulation to find the probabilities
    [Q_stop1, Q_stop2, Q_survive3] = simulate_autocall_probs_NIG(useful_data, sigma_NIG, kappa_NIG, eta_NIG, N_paths);
    
    % 2. Calculate the PV of the floating leg (Euribor 3M + spread)
    PV_A = compute_PV_A_path(useful_data, spread, Q_stop1, Q_stop2, Q_survive3);
    
    % 3. Calculate the PV of the structured leg (Conditional coupons)
    PV_B = compute_PV_B_path(useful_data, coupon_early, coupon_final, Q_stop1, Q_stop2, Q_survive3);
    
    % 4. Calculate the Upfront X% (Party A PV - Party B PV = 0)
    X = PV_A - PV_B;
    
    % Sanity check to verify that probabilities sum to 1
    if abs((Q_stop1 + Q_stop2 + Q_survive3) - 1) > 1e-4
        warning('Simulated probabilities do not sum to 1. Check the Monte Carlo engine.');
    end
end