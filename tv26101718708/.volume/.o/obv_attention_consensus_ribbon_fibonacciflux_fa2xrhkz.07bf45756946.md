Calculation: Standardized OBV slope (for each of four timeframes: short-term, intraday, swing, and position) = clip to [-3, 3] the difference between the current and prior-offset linear regression values of OBV, divided by the rolling standard deviation of OBV; OBV adds volume when close rises, subtracts volume when close falls, and is unchanged when close is unchanged. Use the last completed bar of each timeframe.
Calculation: Sensor change = current standardized OBV slope minus its value on the prior bar of that timeframe.
Calculation: Consensus = weighted mean of the four standardized OBV slopes, using normalized attention weights.
Calculation: Dispersion = square root of the weighted mean squared difference between each standardized OBV slope and the consensus, using the same weights.
Calculation: Concentration = 1 minus dispersion divided by a parameter, clipped to [0, 1].
Calculation: Bullish side share = total weight of sensors above zero; bearish side share = total weight of sensors below zero.
Calculation: Bullish acceleration share = weighted mean of each sensor change divided by a parameter and clipped to [0, 1]; bearish acceleration share = weighted mean of the negative of each sensor change divided by that parameter and clipped to [0, 1].
Calculation: Bullish strength = 100 times the cube root of concentration × bullish side share × bullish acceleration share.
Calculation: Bearish strength = 100 times the cube root of concentration × bearish side share × bearish acceleration share.
Long: Bullish strength ≥ threshold AND bullish strength > bearish strength
Short: Bearish strength ≥ threshold AND bearish strength > bullish strength