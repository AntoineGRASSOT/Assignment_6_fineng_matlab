function [Q_stop1, Q_stop2, Q_survive3] = simulate_autocall_probs_NIG(useful_data, sigma, kappa, eta, N_paths)
% SIMULATE_AUTOCALL_PROBS_NIG Monte Carlo engine for 3y Autocallable
%
% INPUTS:
%   useful_data : Struct containing F0_1y, F0_2y, F0_3y, T1, T2, T3
%   sigma, kappa, eta : NIG parameters
%   N_paths     : Number of Monte Carlo simulations (e.g., 100000)
%
% OUTPUTS:
%   Probabilities of the 3 mutually exclusive scenarios.

    K = 3200; % Fixed strike

    % 1. Calculate time increments (dt)
    dt1 = useful_data.T1;
    dt2 = useful_data.T2 - useful_data.T1;
    dt3 = useful_data.T3 - useful_data.T2;
    
    % Check martingale condition (same for all dt)
    martingale_term = 1 - 2 * kappa * (eta + 0.5 * sigma^2);
    if martingale_term < 0
        error('Invalid parameters: martingale condition violated.');
    end
    
    % Drift compensators for the three steps
    mu_1 = - (dt1 / kappa) * (1 - sqrt(martingale_term));
    mu_2 = - (dt2 / kappa) * (1 - sqrt(martingale_term));
    mu_3 = - (dt3 / kappa) * (1 - sqrt(martingale_term));

    % --- STEP 1 (T1) ---
    Z1 = random('InverseGaussian', dt1, dt1^2 / kappa, N_paths, 1);
    W1 = randn(N_paths, 1);
    dX1 = mu_1 + eta .* Z1 + sigma .* sqrt(Z1) .* W1; % Log-return from 0 to T1
    
    X1 = dX1; % Accumulated noise at T1
    S1 = useful_data.F0_1y .* exp(X1); % Index at T1
    
    % --- STEP 2 (T2) ---
    Z2 = random('InverseGaussian', dt2, dt2^2 / kappa, N_paths, 1);
    W2 = randn(N_paths, 1);
    dX2 = mu_2 + eta .* Z2 + sigma .* sqrt(Z2) .* W2; % Log-return from T1 to T2
    
    X2 = X1 + dX2; % Accumulated noise at T2
    S2 = useful_data.F0_2y .* exp(X2); % Index at T2
    
    % --- STEP 3 (T3) ---
    Z3 = random('InverseGaussian', dt3, dt3^2 / kappa, N_paths, 1);
    W3 = randn(N_paths, 1);
    dX3 = mu_3 + eta .* Z3 + sigma .* sqrt(Z3) .* W3; % Log-return from T2 to T3
    
    X3 = X2 + dX3; % Accumulated noise at T3
    S3 = useful_data.F0_3y .* exp(X3); % Index at T3 (Calculated for completeness)

    % --- SCENARIO EVALUATION (Autocallable Logic) ---
    % Identify which paths stop and where
    
    idx_stop_1 = S1 < K; 
    idx_survive_1 = ~idx_stop_1;
    
    idx_stop_2 = idx_survive_1 & (S2 < K);
    idx_survive_2 = idx_survive_1 & ~idx_stop_2;
    
    % Probabilities are simply the mean of the logical vectors (0s and 1s)
    Q_stop1    = mean(idx_stop_1);
    Q_stop2    = mean(idx_stop_2);
    Q_survive3 = mean(idx_survive_2);
    
end