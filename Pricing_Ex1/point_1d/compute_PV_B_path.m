function PV_B = compute_PV_B_path(useful_data, coupon_early, coupon_final, Q_stop1, Q_stop2, Q_survive3)
% COMPUTE_PV_B_PATH  PV of Party B structured leg for 3Y Autocallable
%
% Scenario 1: Stop in T1 -> Pay 6% in T1
% Scenario 2: Stop in T2 -> Pay 6% in T2
% Scenario 3: Survive to T3 -> Pay 2% in T3

    % 1: Autocall at T1
    PV_B_1 = coupon_early * useful_data.disc_T1 * Q_stop1;
    
    % 2: Autocall at T2
    PV_B_2 = coupon_early * useful_data.disc_T2 * Q_stop2;
    
    % 3: Natural maturity at T3
    PV_B_3 = coupon_final * useful_data.disc_T3 * Q_survive3;
    
    PV_B = PV_B_1 + PV_B_2 + PV_B_3;
end