Calculation: SSL state = 1 when close(T1, still-forming bar) > SMA(high, lookback, T1, last completed bar), -1 when close(T1, still-forming bar) < SMA(low, lookback, T1, last completed bar), otherwise its value on the previous T1 bar; initialize to 0, calculate on T1 bars, and sample on chart bars
Long: SSL state >= 0
Short: SSL state = -1