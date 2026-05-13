function print_results_path(label, X, PV_A, PV_B, Q_stop1, Q_stop2, Q_survive3, Notional)
% PRINT_RESULTS_PATH  Displays pricing results for the 3Y Autocallable model
%
% INPUTS:
%   label      : String with the title of the print block
%   X          : Upfront value (decimal format)
%   PV_A       : Present Value of the floating leg (Party A)
%   PV_B       : Present Value of the structured leg (Party B)
%   Q_stop1    : Probability of early redemption at T1
%   Q_stop2    : Probability of early redemption at T2
%   Q_survive3 : Probability of natural maturity at T3
%   Notional   : Principal amount in EUR

    fprintf('\n=== %s ===\n', label);
    
    % Print Probabilities
    fprintf('  Q(Stop in T1)   = %.6f\n', Q_stop1);
    fprintf('  Q(Stop in T2)   = %.6f\n', Q_stop2);
    fprintf('  Q(Survive T3)   = %.6f\n', Q_survive3);
    
    % Sanity check on probabilities summing to 1 (visual feedback)
    fprintf('  Sum of Qs       = %.6f\n', Q_stop1 + Q_stop2 + Q_survive3);
    
    % Print Present Values
    fprintf('  PV_B (Struct)   = %.6f\n', PV_B);
    fprintf('  PV_A (Euribor)  = %.6f\n', PV_A);
    
    % Print Upfront
    fprintf('  Upfront X%%      = %.4f%%\n', X * 100);
    fprintf('  Upfront EUR     = %.2f\n', X * Notional);
end