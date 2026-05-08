function print_comparison(X_NIG, X_BS, sigma_BS)
% PRINT_COMPARISON  Compares NIG and BS upfront values

fprintf('\n=== Model comparison ===\n');
fprintf('  Implied vol used (BS) = %.4f%%\n', sigma_BS * 100);
fprintf('  NIG upfront  = %.4f%%\n', X_NIG * 100);
fprintf('  BS  upfront  = %.4f%%\n', X_BS  * 100);
fprintf('  Difference   = %.4f%%\n', (X_BS - X_NIG) * 100);
end