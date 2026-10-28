Calculation: buy pressure = sum over the pressure lookback of volume × 1/(1+exp(-1.7055×z)) divided by total volume over that lookback, where z = log(close/previous close) divided by the standard deviation of log returns over the sigma window (z=0 if the standard deviation is 0; pressure=0.5 if total volume is 0)
Long: buy pressure ≥ 0.55
Short: buy pressure ≤ 0.45