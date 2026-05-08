function PV_B = compute_PV_B(useful_data, coupon_1y, coupon_2y, Q_below, Q_survive)

% COMPUTE_PV_B  PV of Party B structured coupon leg
%
% Scenario A (S1 < K): pay coupon_1y at T1, swap cancelled
% Scenario B (S1 >= K): pay coupon_2y at T2, swap matures naturally

PV_B = coupon_1y * useful_data.disc_T1 * Q_below + ...
       coupon_2y * useful_data.disc_T2 * Q_survive;

end