function swapValue = payer_swap_value_HW(t, x, maturity, K, curve, a, sigma)
%PAYER_SWAP_VALUE_HW Compute payer swap value at a Hull-White tree node.
%
% Payer swap value:
%
%   V_payer = Floating Leg - Fixed Leg
%
% In a single-curve framework:
%
%   Floating Leg = 1 - P(t,T_N)
%   Fixed Leg    = K * sum alpha_k * P(t,T_k)
%
% Therefore:
%
%   V_payer = 1 - P(t,T_N) - K * sum alpha_k P(t,T_k)

    %% Annual payment dates after the exercise date
    paymentTimes = (t+1):1:maturity;

    if isempty(paymentTimes)
        swapValue = 0;
        return;
    end

    %% Floating leg value
    P_t_TN = node_zcb_HW(t, maturity, x, curve, a, sigma);
    floatingLeg = 1 - P_t_TN;

    %% Fixed leg value
    fixedLeg = 0;

    for k = 1:length(paymentTimes)
        Tk = paymentTimes(k);

        % First version: annual fixed leg, alpha = 1
        alpha = 1.0;

        P_t_Tk = node_zcb_HW(t, Tk, x, curve, a, sigma);
        fixedLeg = fixedLeg + K * alpha * P_t_Tk;
    end

    %% Payer swap value
    swapValue = floatingLeg - fixedLeg;
end