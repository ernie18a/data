Calculation: R = 100 × (EMA(close, lookback) / SMA(close, same lookback) − 1), calculated on T1 bars; R[n] is the value n T1 bars ago, with R[0] from the bar still forming
Long: R[signal-bar offset] >= R[signal-bar offset + 1] AND R[signal-bar offset + 1] < R[signal-bar offset + 2]
Short: R[signal-bar offset] <= R[signal-bar offset + 1] AND R[signal-bar offset + 1] > R[signal-bar offset + 2]
Exit: short, R[signal-bar offset + 1] < R[signal-bar offset + 2]
Exit: long, R[signal-bar offset + 1] > R[signal-bar offset + 2]