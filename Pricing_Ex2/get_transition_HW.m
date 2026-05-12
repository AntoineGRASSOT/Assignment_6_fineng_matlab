function [next_l, p, branchType] = get_transition_HW(l, lMax, muHat)
%GET_TRANSITION_HW Transition probabilities for the Hull-White trinomial tree.
%
% The tree is built for the zero-mean OU process:
%
%   dx_t = -a x_t dt + sigma dW_t
%
% We use:
%
%   muHat = 1 - exp(-a*dt) > 0
%
% At state index l, the conditional mean moves approximately by:
%
%   - l * muHat
%
% in index units.

    lm = l * muHat;

    if l == -lMax
        %% Branch B: lower boundary
        % next states are shifted upward:
        % l -> l, l+1, l+2
        branchType = 'B';
        next_l = [l, l+1, l+2];

        p_low  = 0.5 * (7/3 + 3*lm + lm^2);       % to l
        p_mid  = -1/3 - 2*lm - lm^2;              % to l+1
        p_high = 0.5 * (1/3 + lm + lm^2);         % to l+2

        p = [p_low, p_mid, p_high];

    elseif l == lMax
        %% Branch C: upper boundary
        % next states are shifted downward:
        % l -> l-2, l-1, l
        branchType = 'C';
        next_l = [l-2, l-1, l];

        p_low  = 0.5 * (1/3 - lm + lm^2);         % to l-2
        p_mid  = -1/3 + 2*lm - lm^2;              % to l-1
        p_high = 0.5 * (7/3 - 3*lm + lm^2);       % to l

        p = [p_low, p_mid, p_high];

    else
        %% Branch A: normal middle branching
        % next states:
        % l -> l-1, l, l+1
        branchType = 'A';
        next_l = [l-1, l, l+1];

        p_low  = 0.5 * (1/3 + lm + lm^2);         % to l-1
        p_mid  = 2/3 - lm^2;                      % to l
        p_high = 0.5 * (1/3 - lm + lm^2);         % to l+1

        p = [p_low, p_mid, p_high];
    end

    %% Numerical cleanup
    p(abs(p) < 1e-14) = 0;

    %% Safety checks
    if any(p < -1e-10)
        warning('Negative probability detected at l = %d: [%g %g %g]', ...
            l, p(1), p(2), p(3));
    end

    if abs(sum(p) - 1) > 1e-10
        warning('Probabilities do not sum to 1 at l = %d. Sum = %.12f', ...
            l, sum(p));
    end
end