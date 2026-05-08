function payment_dates = calc_payment_dates(start_date, years)
%CALC_PAYMENT_DATES Generates a vector of quarterly payment dates
%
%   payment_dates = CALC_PAYMENT_DATES(start_date, years)
%   computes the schedule of quarterly payments starting from a given date
%   and extending for a specified number of years. It applies the 
%   Modified Following Business Convention to ensure payments fall on 
%   valid business days.
%
%   INPUTS:
%       start_date : The initial date of the contract (datenum format)
%       years      : The duration of the contract in years
%
%   OUTPUTS:
%       payment_dates : A column vector of payment dates (datenum format)

    % Calculate total number of quarterly payments
    num_payments = years * 4;
    
    % Pre-allocate the output vector for performance
    payment_dates = zeros(num_payments, 1);
    
    current_date = start_date;
    
    for i = 1:num_payments
        % Add 3 months to the current date
        current_date = datemnth(current_date, 3);
        
        % Apply the Modified Following Business Convention
        % Using the default target calendar (0 = excludes weekends)
        current_date = busdate(current_date - 1, 'modifiedfollow'); 
        
        % Store the valid payment date
        payment_dates(i) = current_date;
    end
end