Calculation: ret = natural log of close minus natural log of previous close (chart timeframe)
Calculation: dvol = volume minus previous bar volume (chart timeframe)
Calculation: U (V) = rank of ret (dvol) in a rolling window of the last N bars including the current bar: count of window values <= the current value, divided by N
Calculation: lambdaL = EMA (short smoothing length) of [count(U<=u AND V<=u) / count(V<=u)], counted over the last N bars of the U,V series including the current bar; raw ratio is 0 if the denominator is 0; u is a tail fraction below 0.5
Calculation: lambdaU = EMA (same smoothing length as lambdaL) of [count(U>=1-u AND V>=1-u) / count(V>=1-u)], counted over the last N bars of the U,V series including the current bar; raw ratio is 0 if the denominator is 0
Long: lambdaU crosses above threshold (previous lambdaU <= threshold AND current lambdaU > threshold) on the completed bar AND current position is not long (flat or short; reverses a short) AND bars since the last entry signal of either side >= cooldown AND (optional) bar datetime within an allowed session window
Short: lambdaL crosses above threshold (previous lambdaL <= threshold AND current lambdaL > threshold) on the completed bar AND current position is not short (flat or long; reverses a long) AND bars since the last entry signal of either side >= cooldown AND (optional) bar datetime within an allowed session window
Exit: long, Short condition is met (close long and reverse to short)
Exit: short, Long condition is met (close short and reverse to long)