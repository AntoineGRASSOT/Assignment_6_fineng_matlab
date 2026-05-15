function print_2c(exerciseTimes, europeanPricesJ, lowerBoundJ, upperBoundJ, bermPrice, Notional)
    fprintf('\n--- Question c: Bermudan Bounds via Jamshidian ---\n');
    fprintf('\n=========================================\n');
    fprintf('European Swaption Prices (Jamshidian)\n');
    fprintf('=========================================\n\n');
    
    for i = 1:length(exerciseTimes)
        priceBps = europeanPricesJ(i) * 1e4;
        fprintf('Exercise at T_alpha = %2dY : %10.4f bps, price %% = %.4f%%, price EUR = %.2f\n', ...
            exerciseTimes(i), priceBps, 100 * europeanPricesJ(i), europeanPricesJ(i) * Notional);
    end
    
    fprintf('\n=========================================\n');
    fprintf('Bermudan Bounds by Jamshidian\n');
    fprintf('=========================================\n\n');
    fprintf('Lower Bound : %10.4f bps, %.4f%%, %.2f EUR\n', ...
        lowerBoundJ * 1e4, lowerBoundJ * 100, lowerBoundJ * Notional);
    fprintf('Upper Bound : %10.4f bps, %.4f%%, %.2f EUR\n', ...
        upperBoundJ * 1e4, upperBoundJ * 100, upperBoundJ * Notional);
        
    fprintf('\nBermudian tree price: %.4f bps, %.4f%%, %.2f EUR\n', ...
        bermPrice * 1e4, bermPrice * 100, bermPrice * Notional);
        
    fprintf('\nCheck Jamshidian lower bound <= Bermudian <= upper bound:\n');
    fprintf('Lower bound <= Bermudian: %d\n', lowerBoundJ <= bermPrice);
    fprintf('Bermudian <= Upper bound: %d\n', bermPrice <= upperBoundJ);
    fprintf('\n');
end