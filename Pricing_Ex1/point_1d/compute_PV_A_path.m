function PV_A = compute_PV_A_path(useful_data, spread, Q_stop1, Q_stop2, Q_survive3)
% COMPUTE_PV_A_PATH  PV of Party A floating leg for 3Y Autocallable
%
% Year 1 (Q1-Q4)  : Always paid (Prob = 1)
% Year 2 (Q5-Q8)  : Paid if survives T1 (Prob = 1 - Q_stop1)
% Year 3 (Q9-Q12) : Paid if survives T1 and T2 (Prob = Q_survive3)

    cf = useful_data.fwd_rates + spread;
    
    % Year 1: 100% paid
    PV_A_yr1 = sum(useful_data.delta(1:4) .* cf(1:4) .* useful_data.disc_pay(1:4));
    
    % Year 2: Paid if it survives T1 (i.e., 1 - probability of stopping at T1)
    prob_yr2 = 1 - Q_stop1; 
    PV_A_yr2 = prob_yr2 * sum(useful_data.delta(5:8) .* cf(5:8) .* useful_data.disc_pay(5:8));
    
    % Year 3: Paid if it survives up to T3
    prob_yr3 = Q_survive3;
    PV_A_yr3 = prob_yr3 * sum(useful_data.delta(9:12) .* cf(9:12) .* useful_data.disc_pay(9:12));
    
    PV_A = PV_A_yr1 + PV_A_yr2 + PV_A_yr3;
end