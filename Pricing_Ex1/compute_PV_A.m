function PV_A = compute_PV_A(useful_data, spread, Q_survive)

% COMPUTE_PV_A  PV of Party A floating leg (Euribor 3M + spread, quarterly)
%
% Year 1 quarters: always paid (no early redemption possible during year 1)
% Year 2 quarters: paid only if swap survives past T1, weighted by Q_survive

cf = useful_data.fwd_rates + spread;

PV_A_yr1 = sum(useful_data.delta(1:4) .* cf(1:4) .* useful_data.disc_pay(1:4));
PV_A_yr2 = Q_survive * sum(useful_data.delta(5:8) .* cf(5:8) .* useful_data.disc_pay(5:8));
PV_A = PV_A_yr1 + PV_A_yr2;

end