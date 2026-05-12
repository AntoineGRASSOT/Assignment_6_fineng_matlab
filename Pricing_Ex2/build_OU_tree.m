function tree = build_OU_tree(a, sigma, dt, N)
%BUILD_OU_TREE Build a recombining trinomial tree for the zero-mean OU factor.
%
% The zero-mean OU process is:
%
%   dx_t = -a x_t dt + sigma dW_t
%
% The tree is built for x_t, not directly for the short rate r_t.

    %% One-step conditional standard deviation
    sigmaHat = sigma * sqrt((1 - exp(-2*a*dt)) / (2*a));

    %% Grid spacing from Hull-White trinomial tree
    dx = sqrt(3) * sigmaHat;

    %% Mean-reversion coefficient
    muHat = 1 - exp(-a*dt);

    %% Boundary index
    % This choice is based on the positivity condition of transition probabilities.
    lMax = ceil(0.184 / abs(muHat));

    %% Store parameters
    tree.a = a;
    tree.sigma = sigma;
    tree.dt = dt;
    tree.N = N;
    tree.sigmaHat = sigmaHat;
    tree.dx = dx;
    tree.muHat = muHat;
    tree.lMax = lMax;

    %% State grid
    tree.lGrid = (-lMax:lMax)';
    tree.xGrid = tree.lGrid * dx;
end