Calculation: Stochastic K = smoothed stochastic %K, using a longer lookback for the raw %K than for its smoothing
Calculation: Stochastic D = moving average of Stochastic K using a shorter lookback than the raw %K lookback
Calculation: Higher-timeframe K = linear regression of Stochastic K calculated on a higher timeframe, using the higher-timeframe bar still forming
Calculation: Higher-timeframe D = linear regression of Stochastic D calculated on a higher timeframe, using the higher-timeframe bar still forming
Long: Higher-timeframe K crosses above 50 AND Stochastic K > 50 AND Stochastic K > its previous value AND Stochastic K > Stochastic D AND Higher-timeframe K > Higher-timeframe D
Short: Higher-timeframe D crosses below 50 AND Stochastic K < 50 AND Stochastic K < its previous value AND Stochastic K < Stochastic D AND Higher-timeframe K < Higher-timeframe D
Exit: long, Higher-timeframe D crosses below the upper threshold; after the exit order is placed, price falls by the trailing distance from its highest price since placement
Exit: short, Higher-timeframe K crosses above the lower threshold; after the exit order is placed, price rises by the trailing distance from its lowest price since placement