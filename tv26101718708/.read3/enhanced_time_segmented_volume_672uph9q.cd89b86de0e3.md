Calculation: time segmented volume = TSV(close, volume, lookback)
Long: time segmented volume > SMA(time segmented volume, MA lookback) AND time segmented volume > 0
Short: time segmented volume < SMA(time segmented volume, MA lookback) AND time segmented volume < 0
Exit: long, time segmented volume < SMA(time segmented volume, MA lookback) AND time segmented volume > 0
Exit: short, time segmented volume > SMA(time segmented volume, MA lookback) AND time segmented volume < 0