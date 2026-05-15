function value = coupon_bond_value_HW(t, x, Tj, c, curve, a, sigma)
%COUPON_BOND_VALUE_HW Coupon bond value at a Hull-White node.
%
% value = sum_j c_j P(t,Tj;x)

    value = 0;

    for j = 1:length(Tj)
        value = value + c(j) * node_zcb_HW(t, Tj(j), x, curve, a, sigma);
    end

end