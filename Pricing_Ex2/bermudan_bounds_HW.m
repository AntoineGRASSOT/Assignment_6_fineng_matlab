function [lowerBound, upperBound, europeanPrices] = bermudan_bounds_HW( exerciseTimes, maturity, K, curve, a, sigma)
%BERMUDAN_BOUNDS_HW
%
% Compute lower and upper bounds for a Bermudan payer
% swaption using Jamshidian European swaptions.
%
% INPUTS
% -------
% exerciseTimes : vector of Bermudan exercise dates
% maturity      : swap maturity
% K             : fixed strike
% curve         : market curve structure
% a             : HW mean reversion
% sigma         : HW volatility
%
% OUTPUTS
% --------
% lowerBound     : lower bound
% upperBound     : upper bound
% europeanPrices : European swaption prices

    nExercise = length(exerciseTimes);

    europeanPrices = zeros(nExercise,1);

    for i = 1:nExercise

        Talpha = exerciseTimes(i);

        europeanPrices(i) = jamshidian_swaption_HW(Talpha, maturity, K, curve, a, sigma);

    end

    % Lower bound
    lowerBound = max(europeanPrices);

    % Upper bound
    upperBound = sum(europeanPrices);

end