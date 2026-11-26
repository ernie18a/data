Calculation: Breakout range high/low = high/low of the earliest bar with minimum volume in the configured opening-range window ending at the decision bar
Calculation: Long stop = latest confirmed PivotLow(low, swing lookback, swing lookback) captured at entry
Calculation: Short stop = latest confirmed PivotHigh(high, swing lookback, swing lookback) captured at entry
Calculation: Long target = entry price + (entry price − long stop) × risk/reward parameter
Calculation: Short target = entry price − (short stop − entry price) × risk/reward parameter
Long: At the confirmed bar closing at the configured decision time, on the first trade of the session day while flat and with a breakout range, close > breakout range high AND latest confirmed PivotLow(low, swing lookback, swing lookback) < close
Short: At the confirmed bar closing at the configured decision time, on the first trade of the session day while flat and with a breakout range, close < breakout range low AND latest confirmed PivotHigh(high, swing lookback, swing lookback) > close
Long: After the first trade of the session day was a short exited at its stop, while flat on a confirmed bar and before any reverse trade that day, latest confirmed PivotLow(low, swing lookback, swing lookback) < close
Short: After the first trade of the session day was a long exited at its stop, while flat on a confirmed bar and before any reverse trade that day, latest confirmed PivotHigh(high, swing lookback, swing lookback) > close
Exit: long, low ≤ long stop OR high ≥ long target
Exit: short, high ≥ short stop OR low ≤ short target