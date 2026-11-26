Calculation: First line = selected moving average(Stochastic %K(SMA(close, input-processing lookback), extremum lookback, denominator floored at minimum price increment) − 50, smoothing method, smoothing lookback, phase) on T1 bars
Calculation: Second line = selected moving average(First line, same smoothing method, same smoothing lookback, same phase) on T1 bars
Calculation: Strong up state = First line > Second line AND (First line > upper threshold OR (First line > lower threshold AND Second line <= lower threshold))
Calculation: Strong down state = First line <= Second line AND (First line < lower threshold OR (Second line > upper threshold AND First line <= upper threshold))
Calculation: Weak up state = First line > Second line AND NOT Strong up state
Calculation: Weak down state = First line <= Second line AND NOT Strong down state
Long: First line > Second line
Short: First line <= Second line
Long: Strong up state on the last completed T1 bar AND NOT Strong up state on the T1 bar still forming
Short: Strong down state on the last completed T1 bar AND NOT Strong down state on the T1 bar still forming
Exit: long, Weak down state on the last completed T1 bar OR (Strong down state on the last completed T1 bar AND Strong down state on the T1 bar still forming)
Exit: short, Weak up state on the last completed T1 bar OR (Strong up state on the last completed T1 bar AND Strong up state on the T1 bar still forming)
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance