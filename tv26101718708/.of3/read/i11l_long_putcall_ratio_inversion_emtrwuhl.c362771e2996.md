Calculation: smoothed ratio = SMA(T1 close sampled on chart bars (last completed T1 bar historically; still-forming T1 bar in realtime), ratio lookback)
Calculation: ratio mean = SMA(smoothed ratio, band lookback) on chart bars
Calculation: ratio deviation = STDEV(smoothed ratio, band lookback) on chart bars
Long: smoothed ratio crosses below ratio mean + deviation multiple * ratio deviation
Short: smoothed ratio crosses above ratio mean - deviation multiple * ratio deviation
Exit: short, smoothed ratio > ratio mean
Exit: long, entry price * (1 - stop-loss percentage) > low
Exit: short, entry price * (1 + stop-loss percentage) < high
Exit: long, entry price * (1 + stop-loss percentage * reward-risk multiple) < high
Exit: short, entry price * (1 + stop-loss percentage * reward-risk multiple) < high