function zRates = zeroRates(dates, discounts)
%   zeroRates : compute zero rates from discounts
%
% INPUT
%   dates: dates' vector of expiries
%   discounts: discounts' vector with respect to corresponding dates
%
% OUTPUT
%   zRates : zero rates of the corrisponding dates
  
    settlements = datetime(2008,2,19);
    set=datenum(settlements);

    % year fraction for each date
    frac = yearfrac(set, dates(1:length(discounts)),3);
    
    % zero rate computation
    zRates = -log(discounts)./frac;
end