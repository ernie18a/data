Calculation: PSI = EMA(RSI(close), shorter lookback) scaled by a constant
Calculation: PSI-volume weighted moving average = sum(close × volume × PSI over a lookback) / sum(volume × PSI over the same lookback)
Calculation: PSI-adaptive RMA = recursively smoothed close, with smoothing length decreasing as PSI’s relative deviation from its center increases, bounded by minimum and maximum lengths
Calculation: Thrust histogram = PSI-adaptive RMA − PSI-volume weighted moving average
Calculation: Signal line = weighted moving average of the thrust histogram
Long: Thrust histogram crosses above zero OR (thrust histogram ≥ 0 AND thrust histogram > its prior value) OR thrust histogram crosses above the signal line
Short: Thrust histogram crosses below zero OR (thrust histogram < 0 AND thrust histogram < its prior value) OR thrust histogram crosses below the signal line
Exit: long, (thrust histogram ≥ 0 AND thrust histogram < its prior value) OR thrust histogram crosses below the signal line
Exit: short, (thrust histogram < 0 AND thrust histogram > its prior value) OR thrust histogram crosses above the signal line