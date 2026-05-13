function [X, PV_A, PV_B] = price_upfront_BS_path(coupon_early, coupon_final, sigma_BS, spread, useful_data, N_paths)
% PRICE_UPFRONT_BS_PATH  Prices the upfront X% using Black Monte Carlo

    % 1. Run the Black Monte Carlo simulation 
    [Q_stop1, Q_stop2, Q_survive3] = simulate_autocall_probs_Black(useful_data, sigma_BS, N_paths);
    
    % 2. Calculate the PV of the floating leg (Euribor 3M + spread)
    % -> We REUSE the exact same function from point d!
    PV_A = compute_PV_A_path(useful_data, spread, Q_stop1, Q_stop2, Q_survive3);
    
    % 3. Calculate the PV of the structured leg (Conditional coupons)
    % -> We REUSE the exact same function from point d!
    PV_B = compute_PV_B_path(useful_data, coupon_early, coupon_final, Q_stop1, Q_stop2, Q_survive3);
    
    % 4. Calculate the Upfront X%
    X = PV_A - PV_B;
    
end