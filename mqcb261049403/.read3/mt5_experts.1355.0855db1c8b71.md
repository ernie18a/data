Calculation: trend scores = on T1 bars, let change = close - previous T1 close, up = max(change, 0), down = max(-change, 0), cumulative up = up + previous cumulative up when change > 0, otherwise 0, and cumulative down = down + previous cumulative down when change <= 0, otherwise 0; upper = sum of up over the lookback minus sum of cumulative down over the lookback; lower = sum of down over the lookback minus sum of cumulative up over the lookback
Long: T1 forming-bar upper > lower
Short: T1 forming-bar upper < lower
Long: long-entry enabled AND, on chart bars using T1 values, last completed-bar upper > lower AND forming-bar upper <= lower
Short: short-entry enabled AND, on chart bars using T1 values, last completed-bar upper < lower AND forming-bar upper >= lower
Exit: long, long-exit enabled AND, on chart bars using T1 values, last completed-bar upper < lower
Exit: short, short-exit enabled AND, on chart bars using T1 values, last completed-bar upper > lower