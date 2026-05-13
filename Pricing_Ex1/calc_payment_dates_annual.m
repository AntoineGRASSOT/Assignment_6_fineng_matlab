function payment_dates = calc_payment_dates_annual(start_date, years)

num_payments = years;  % one payment per year
payment_dates = zeros(num_payments, 1);
current_date = start_date;

for i = 1:num_payments
    current_date = datemnth(current_date, 12);  % add 12 months
    current_date = busdate(current_date - 1, 'follow');
    payment_dates(i) = current_date;
end

end