function I = hw_variance_integral(t, T, a, sigma)
%HW_VARIANCE_INTEGRAL Compute integral_0^t beta(u,T)^2 du.
%
% beta(u,T) = sigma/a * (1 - exp(-a*(T-u)))
%
% I = integral_0^t beta(u,T)^2 du

    if t <= 0
        I = 0;
        return;
    end

    term1 = t;

    term2 = 2 * (exp(-a*(T-t)) - exp(-a*T)) / a;

    term3 = (exp(-2*a*(T-t)) - exp(-2*a*T)) / (2*a);

    I = (sigma^2 / a^2) * (term1 - term2 + term3);
end