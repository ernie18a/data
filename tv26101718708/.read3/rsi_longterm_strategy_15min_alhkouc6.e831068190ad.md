Long: RSI(close, lookback) <= oversold threshold AND SMA(close, shorter lookback) > SMA(close, longer lookback) AND volume > volume multiplier * SMA(volume, lookback)
Short: RSI(close, lookback) > overbought threshold AND SMA(close, shorter lookback) < SMA(close, longer lookback) AND volume > volume multiplier * SMA(volume, lookback)
Exit: long, SMA(close, shorter lookback) crosses below SMA(close, longer lookback)
Exit: long, low <= entry price * (1 - stop-loss percentage)