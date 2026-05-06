function [dates, discounts, zRates]=bootstrap(datesSet, ratesSet)

% bootstrap  This function computes the discount factors and zero rates using the bootstrap method.
%
% INPUTS:
%   datesSet  = Structure containing key dates for deposits, futures, and swaps.
%   ratesSet  = Structure containing bid-ask rates for deposits, futures, and swaps.
%
% OUTPUTS:
%   dates     = Vector of dates corresponding to calculated discount factors.
%   discounts = Vector of discount factors computed using bootstrap.
%   zeroRates = Vector of zero rates


% ACT_360 = 2; yearfrac ACT_360 (day-count depo and future convenction)
% ACT_365 = 3; yearfrac ACT_365 (day-count zero rate convenction)
% European_30_360 = 6; yearfrac 30/360 European (day-count swap convenction)

%% initializing variables
% arrays to store the outputs
dates=zeros(61,1);     
discounts=zeros(61,1);  
zRates=zeros(61,1);

dates(1)=datesSet.settlement;   % settlement date
discounts(1)=1;                 % initial discount factor
zRates(1)=0;                 % initial zero rate

% calculate the mid rates are the average of bid and ask rates
rate_mid_depos=(ratesSet.depos(:,1)+ratesSet.depos(:,2))/(2);  
rate_mid_futures=(ratesSet.futures(:,1)+ratesSet.futures(:,2))/2;

% setting first dates of the array
dates(2:4)=datesSet.depos(1:3);
dates(5:11)=datesSet.futures(1:7,2); % expiry dates
rate_mid_swaps=(ratesSet.swaps(:,1)+ratesSet.swaps(:,2))/2; % expiry dates

%% DEPOS
% calulate discounts and rates for deposits
discounts(2:4)=1./(1+(yearfrac(dates(1),dates(2:4),2).*rate_mid_depos(1:3)));
zRates(2:4)=zeroRates(dates(2:4), discounts(2:4));


%% FUTURES

% the first future has the same date as the deposit
B_ti_tii=1/(1+rate_mid_futures(1)*yearfrac(datesSet.futures(1,1),datesSet.futures(1,2),2));
discounts(5)=discounts(4)*B_ti_tii;
zRates(5)=zeroRates(dates(5),discounts(5));

% all the other futures
for i=2:7

    B_ti_tii=1/(1+rate_mid_futures(i)*yearfrac(datesSet.futures(i,1),datesSet.futures(i,2),2));

    % control dates and do interpolation or not
    if datesSet.futures(i,1)==datesSet.futures(i-1,2)
        discounts(i+4)=discounts(i+3)*B_ti_tii;
    elseif(datesSet.futures(i,1) > datesSet.futures(i-1,2))
        zerorate = zeroRates(dates(i+3), discounts(i+3));
        B_t0_ti = exp(-yearfrac(datesSet.settlement, datesSet.futures(i,1),3)*zerorate);
        discounts(i+4)=B_t0_ti*B_ti_tii;
    else
        zerorate = zeroRates(dates(i+2:i+3), discounts(i+2:i+3));
        zerorateinterpl = interp1(dates(i+2:i+3), zerorate, datesSet.futures(i,1),'linear');
        B_t0_ti = exp(-yearfrac(datesSet.settlement, datesSet.futures(i,1),3)*zerorateinterpl);
        discounts(i+4)=B_t0_ti*B_ti_tii;
    end
    
    zRates(i+4)=zeroRates(dates(i+4),discounts(i+4)); % zero rate for each step
end

%% SWAP

% I find the position of the expiry of the first swap in the date array  in
% order to compute the zero rate aand the discount factor
firstSwapExpity = datesSet.swaps(1);
pos = find(dates > firstSwapExpity,1); % position in dates

zerorate = zeroRates(dates(pos-1:pos), discounts(pos-1:pos));
rateswaptemp=interp1(dates(pos-1:pos),zerorate, firstSwapExpity,"linear");

dates = [dates(1:pos-1); firstSwapExpity; dates(pos:end-1)]; % update the date line

disc_swap=exp(-yearfrac(datesSet.settlement,firstSwapExpity,3)*rateswaptemp);
discounts = [discounts(1:pos-1); disc_swap; discounts(pos:end-1)]; % insert the discount in the right space

zerorate=zeroRates(firstSwapExpity,disc_swap); % compute the zero rate
zRates = [zRates(1:pos-1); zerorate; zRates(pos:end-1)];

% do all the other swap
dates(13:end)=datesSet.swaps(2:end); % update all teh dates

sum=yearfrac(datesSet.settlement,dates(pos),6)*disc_swap;

for i=1:49
    if i==1
        discounts(12+i)=(1-rate_mid_swaps(i+1)*sum)/(1+yearfrac(dates(pos),dates(12+i),6)*rate_mid_swaps(i+1));
        sum=sum+yearfrac(dates(pos),dates(12+i),6)*discounts(i+12);
    else 
        discounts(12+i)=(1-rate_mid_swaps(i+1)*sum)/(1+yearfrac(dates(11+i),dates(12+i),6)*rate_mid_swaps(i+1));
        sum=sum+yearfrac(dates(11+i),dates(12+i),6)*discounts(i+12);
    end

    zRates(12+i)=zeroRates(dates(12+i),discounts(12+i));
end


% in outputs only expiry dates
dates=dates(2:end);
discounts=discounts(2:end);
zRates=zRates(2:end);
