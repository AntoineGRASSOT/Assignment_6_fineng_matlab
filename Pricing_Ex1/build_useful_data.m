function useful_data = build_useful_data(start_date, T, S0, q, K_strike, dates, T_curve, zRates)

% build_useful_data  Computes all dates, day fractions, discount factors
%                 and forward Euribor rates needed for pricing

s = start_date;
% Dates
useful_data.float_pay_dates  = calc_payment_dates(s, T);
useful_data.float_fix_dates  = busdate(useful_data.float_pay_dates - 2, 'previous');
useful_data.cpn_pay_dates    = calc_payment_dates_annual(s, T);
useful_data.cpn_reset_dates  = busdate(useful_data.cpn_pay_dates - 2, 'previous');
all_dates = [s; useful_data.float_pay_dates];
useful_data.delta = yearfrac(all_dates(1:end-1), all_dates(2:end), 2); % act 360

% DF quarterly
useful_data.disc_pay = arrayfun(@(d) ...
    discount_from_zrate(start_date, d, dates, zRates), ...
    useful_data.float_pay_dates);

% DF annual
useful_data.T1    = yearfrac(dates(1), useful_data.cpn_pay_dates(1), 3);
useful_data.T2    = yearfrac(dates(1), useful_data.cpn_pay_dates(2), 3);
useful_data.r_1y  = interp1(T_curve, zRates, useful_data.T1, 'linear');
useful_data.r_2y  = interp1(T_curve, zRates, useful_data.T2, 'linear');
r_1y = useful_data.r_1y ; r_2y = useful_data.r_2y ; 
T1 = useful_data.T1;  T2 = useful_data.T2 ; 
useful_data.disc_T1 = exp(-r_1y * T1);
useful_data.disc_T2 = exp(-r_2y * T2);

% Euribor 3m
disc_all = [1; useful_data.disc_pay];
useful_data.fwd_rates = (1 ./ useful_data.delta) .* ...
    (disc_all(1:8) ./ disc_all(2:9) - 1);

useful_data.F0_1y = S0 * exp((useful_data.r_1y - q) * useful_data.T1);
useful_data.d_log = log(K_strike / useful_data.F0_1y);

end