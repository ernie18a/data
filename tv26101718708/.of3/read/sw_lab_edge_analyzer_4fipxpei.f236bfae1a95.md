Long: RSI(close, lookback) crosses above oversold threshold
Short: RSI(close, lookback) crosses below overbought threshold
Long: SMA(close, shorter lookback) crosses above SMA(close, longer lookback)
Short: SMA(close, shorter lookback) crosses below SMA(close, longer lookback)
Long: close > highest(high, lookback)[1] AND volume > SMA(volume, separate lookback) * multiplier
Short: close < lowest(low, lookback)[1] AND volume > SMA(volume, separate lookback) * multiplier
Long: Z-score(close, lookback) < -threshold
Short: Z-score(close, lookback) > threshold