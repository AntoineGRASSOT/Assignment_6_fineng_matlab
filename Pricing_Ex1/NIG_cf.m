function cf = NIG_cf(xi, sigma, kappa, eta, T)
% NIG characteristic function — Normal Mean Variance Mixture, alpha=1/2
% the same as we did in previous lab
% phi(u) = exp(i*mu*u) * exp(T/kappa * (1 - sqrt(1 - 2*kappa*(i*eta*u - sigma^2*u^2/2))))
%
% martingale condition phi(-i) = 1 fixes mu
%
% martingale drift: set u = -i in the exponent part

mu = -(T/kappa) * (1 - sqrt(1 - 2*kappa*(eta + sigma^2/2)));
inner = 1 - 2*kappa*(1i*eta*xi - sigma^2*xi.^2/2); % u=xi

log_cf = 1i*mu*xi + (T/kappa)*(1 - sqrt(inner)); % log CF
cf = exp(log_cf);

end