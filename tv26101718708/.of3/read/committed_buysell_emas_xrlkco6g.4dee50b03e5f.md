Calculation: percentage change = 100 * (close - close[1]) / close[1]
Long: volume > strong volume multiplier * SMA(volume, average volume lookback) AND percentage change > strong percentage threshold
Long: volume > baseline volume multiplier * SMA(volume, average volume lookback) AND percentage change > change threshold AND (volume <= strong volume multiplier * SMA(volume, average volume lookback) OR percentage change <= strong percentage threshold)
Short: volume > baseline volume multiplier * SMA(volume, average volume lookback) AND percentage change < change threshold