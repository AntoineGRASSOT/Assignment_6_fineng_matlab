function [Q_stop1, Q_stop2, Q_survive3] = simulate_autocall_probs_Black(useful_data, sigma_BS, N_paths)
% SIMULATE_AUTOCALL_PROBS_BLACK Monte Carlo engine for 3y Autocallable using Black (GBM)
%
% INPUTS:
%   useful_data : Struct containing F0_1y, F0_2y, F0_3y, T1, T2, T3
%   sigma_BS    : Black implied volatility for the strike of interest
%   N_paths     : Number of Monte Carlo simulations

    K = 3200; % Fixed strike

    % 1. Time increments (dt)
    dt1 = useful_data.T1;
    dt2 = useful_data.T2 - useful_data.T1;
    dt3 = useful_data.T3 - useful_data.T2;
    
    % --- STEP 1 (T1) ---
    % Black-Scholes dynamics: dX = -0.5 * sigma^2 * dt + sigma * sqrt(dt) * Z
    dX1 = -0.5 * sigma_BS^2 * dt1 + sigma_BS * sqrt(dt1) * randn(N_paths, 1);
    X1 = dX1;
    S1 = useful_data.F0_1y .* exp(X1);
    
    % --- STEP 2 (T2) ---
    dX2 = -0.5 * sigma_BS^2 * dt2 + sigma_BS * sqrt(dt2) * randn(N_paths, 1);
    X2 = X1 + dX2;
    S2 = useful_data.F0_2y .* exp(X2);
    
    % --- STEP 3 (T3) ---
    dX3 = -0.5 * sigma_BS^2 * dt3 + sigma_BS * sqrt(dt3) * randn(N_paths, 1);
    X3 = X2 + dX3;
    S3 = useful_data.F0_3y .* exp(X3);

    % --- SCENARIO EVALUATION (Autocallable Logic) ---
    idx_stop_1 = S1 < K; 
    idx_survive_1 = ~idx_stop_1;
    
    idx_stop_2 = idx_survive_1 & (S2 < K);
    idx_survive_2 = idx_survive_1 & ~idx_stop_2;
    
    Q_stop1    = mean(idx_stop_1);
    Q_stop2    = mean(idx_stop_2);
    Q_survive3 = mean(idx_survive_2);
    
end