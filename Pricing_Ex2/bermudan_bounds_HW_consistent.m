function [lowerBound, upperBound, europeanPrices] = bermudan_bounds_HW_consistent(exerciseTimes, maturity, K, curve, a, sigma)
%BERMUDAN_BOUNDS_HW_CONSISTENT
%
% Compute lower and upper bounds for a Bermudan payer swaption
% using Jamshidian European swaptions.
%
% This version calls jamshidian_swaption_HW_consistent.

    nExercise = length(exerciseTimes);
    europeanPrices = zeros(nExercise, 1);

    for i = 1:nExercise
        Talpha = exerciseTimes(i);

        europeanPrices(i) = jamshidian_swaption_HW_consistent( ...
            Talpha, maturity, K, curve, a, sigma);
    end

    lowerBound = max(europeanPrices);
    upperBound = sum(europeanPrices);

end