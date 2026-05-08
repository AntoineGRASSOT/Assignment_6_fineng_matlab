function print_results(label, X, PV_A, PV_B, Q, Notional)
% PRINT_RESULTS  Displays pricing results for one model

fprintf('\n=== %s ===\n', label);
fprintf('  Q(S1 < K)   = %.6f\n',   Q.below);
fprintf('  Q(S1 >= K)  = %.6f\n',   Q.survive);
fprintf('  PV_B        = %.6f\n',   PV_B);
fprintf('  PV_A        = %.6f\n',   PV_A);
fprintf('  Upfront X%%  = %.4f%%\n', X * 100);
fprintf('  Upfront EUR = %.2f\n',   X * Notional);
end