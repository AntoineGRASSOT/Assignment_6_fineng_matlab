%% 
clc; clear all;
addpath("data\")
addpath("Pricing_Ex1\")
addpath("utilities\")

%% Parameters
load('eurostoxx_Poli.mat')
formatDate = 'dd/mm/yyyy';
% bootstrap datas to compute zero rates
[datesSet, ratesSet] = readExcelData('MktData_CurveBootstrap.xls', formatDate);
[dates, discounts, zRates]=bootstrap(datesSet, ratesSet);
T_curve = yearfrac(dates(1), dates, 3); % ACT/365

%% Ex1
% Parameters
Notional   = 100e6;
spread     = 0.013;                    T          = 2;
start_date = datenum('19-Feb-2008');
S0         = cSelect.reference;        q          = cSelect.dividends;
coupon_1y  = 0.06;                     coupon_2y  = 0.02;
K_strike   = 3200;                     sigma_NIG  = 0.20;
kappa_NIG  = 1;                        eta_NIG    = 3;
useful_data = build_useful_data(start_date, T, S0, q, K_strike, dates, T_curve, zRates);

% Point a — NIG pricing
[X_NIG, PV_A_NIG, PV_B_NIG, Q_NIG] = price_upfront_NIG(coupon_1y, coupon_2y, sigma_NIG, kappa_NIG, eta_NIG, spread, useful_data);
print_results('Point a — NIG', X_NIG, PV_A_NIG, PV_B_NIG, Q_NIG, Notional);

% Point b — Black-Scholes pricing
sigma_BS = interp1(cSelect.strikes, cSelect.surface, K_strike, 'linear');
[X_BS, PV_A_BS, PV_B_BS, Q_BS] = price_upfront_BS(K_strike, spread, coupon_1y, coupon_2y, useful_data, sigma_BS);
print_results('Point b — Black-Scholes', X_BS, PV_A_BS, PV_B_BS, Q_BS, Notional);

% Comparison
print_comparison(X_NIG, X_BS, sigma_BS);

% point c
% only discussion in the report

% point d
% now we need the distributions of S1 and S2 jointly, we cannot use what we
% did before, maybe Monte Carlo NIG

% point e

%% Ex2