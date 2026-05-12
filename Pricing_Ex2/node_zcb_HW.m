function P_tT = node_zcb_HW(t, T, x, curve, a, sigma)
%NODE_ZCB_HW Zero-coupon bond price at a Hull-White tree node.
%
% Computes P(t,T) at node value x_t = x.
%
% Formula:
% P(t,T) = P(0,T)/P(0,t) *
%          exp( -B(t,T)*x
%               -0.5 * integral_0^t [beta(u,T)^2 - beta(u,t)^2] du )
%
% where
% B(t,T) = (1 - exp(-a*(T-t))) / a

    if T < t
        error('Maturity T must be greater than or equal to current time t.');
    end

    if abs(T - t) < 1e-12
        P_tT = 1.0;
        return;
    end

    %% Market discount factors
    P0T = market_discount_HW(curve, T);
    P0t = market_discount_HW(curve, t);

    %% Hull-White B coefficient
    B = (1 - exp(-a*(T - t))) / a;

    %% Variance adjustment
    I_T = hw_variance_integral(t, T, a, sigma);
    I_t = hw_variance_integral(t, t, a, sigma);

    varianceAdjustment = I_T - I_t;

    %% Node zero-coupon bond price
    P_tT = (P0T / P0t) * exp(-B * x - 0.5 * varianceAdjustment);
end