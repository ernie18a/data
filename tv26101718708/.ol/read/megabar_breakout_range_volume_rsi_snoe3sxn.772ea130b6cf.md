Calculation: Range = absolute difference between the bar's close and open
Long: close > open AND volume > SMA(volume, volume lookback) × volume multiplier AND Range > SMA(Range, range lookback) × range multiplier AND moving average of RSI > long threshold
Short: close < open AND volume > SMA(volume, volume lookback) × volume multiplier AND Range > SMA(Range, range lookback) × range multiplier AND moving average of RSI < short threshold
Exit: Long, high >= entry price + take-profit distance OR low <= entry price - stop-loss distance
Exit: Short, low <= entry price - take-profit distance OR high >= entry price + stop-loss distance