function swapRate = par_swap_rate_HW(t, x, maturity, curve, a, sigma)
%PAR_SWAP_RATE_HW Compute par swap rate at a HW tree node.
%
% S(t) = (1 - P(t,T_N)) / sum alpha_k P(t,T_k)

    paymentTimes = (t+1):1:maturity;

    if isempty(paymentTimes)
        swapRate = NaN;
        return;
    end

    P_t_TN = node_zcb_HW(t, maturity, x, curve, a, sigma);

    annuity = 0;

    for k = 1:length(paymentTimes)
        Tk = paymentTimes(k);
        alpha = 1.0;
        P_t_Tk = node_zcb_HW(t, Tk, x, curve, a, sigma);
        annuity = annuity + alpha * P_t_Tk;
    end

    swapRate = (1 - P_t_TN) / annuity;
end