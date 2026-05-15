function print_2b(stepsList, prices, exerciseTimes, euroPricesTree, lowerBoundTree, upperBoundTree, bermPrice, Notional)
    fprintf('\n--- Question b: Tree Validation ---\n');
    fprintf('\nConvergence test:\n');
    for s = 1:length(stepsList)
        fprintf('stepsPerYear = %2d, price = %.8f, price %% = %.4f%%, price = %.2f EUR\n', ...
            stepsList(s), prices(s), 100 * prices(s), prices(s) * Notional);
    end

    fprintf('\nTree-based European-style prices over all exercise dates:\n');
    for j = 1:length(exerciseTimes)
        fprintf('Exercise at %.0fy: European-style price = %.8f, price %% = %.4f%%, price = %.4f bps\n', ...
            exerciseTimes(j), euroPricesTree(j), 100 * euroPricesTree(j), 10000 * euroPricesTree(j));
    end

    fprintf('\nTree lower bound = max European-style prices = %.8f\n', lowerBoundTree);
    fprintf('Bermudian price = %.8f\n', bermPrice);
    fprintf('Tree upper bound = sum European-style prices = %.8f\n', upperBoundTree);
    
    fprintf('\nCheck tree lower bound <= Bermudian <= upper bound:\n');
    fprintf('Lower bound <= Bermudian: %d\n', lowerBoundTree <= bermPrice);
    fprintf('Bermudian <= Upper bound: %d\n', bermPrice <= upperBoundTree);
end