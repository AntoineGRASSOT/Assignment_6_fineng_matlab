function prob = NIG_cdf(d, sigma, kappa, eta, T)
% NIG_CDF  Computes Q(X < d) 
%
% INPUTS:
%   d     : threshold = log(K/F0), the log-moneyness
%   sigma : volatility parameter
%   kappa : IG variance parameter  
%   eta   : skewness parameter
%   T     : maturity in years
%
% OUTPUT:
%   prob  : Q(X < d) under NIG risk-neutral measure

% CF of log-return X
cf = @(xi) NIG_cf(xi, sigma, kappa, eta, T);

% Gil-Pelaez integrand: Im(exp(-i*xi*d) * cf(xi) / xi)
integrand = @(xi) imag(exp(-1i * xi * d) .* cf(xi) ./ xi);
I = integral(integrand, 1e-8, 500, 'RelTol', 1e-6, 'AbsTol', 1e-8);
prob = 0.5 - (1/pi) * I;

end