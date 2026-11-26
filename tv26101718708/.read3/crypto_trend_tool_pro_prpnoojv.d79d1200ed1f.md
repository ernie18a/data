Long: close > EMA(close, trend lookback)
Short: close <= EMA(close, trend lookback)
Long: RSI(close, RSI lookback) < oversold threshold
Short: RSI(close, RSI lookback) > overbought threshold
Long: close crosses above EMA(close, trend lookback) AND (volume filter disabled OR volume > SMA(volume, volume lookback)) AND (RSI filter disabled OR RSI(close, RSI lookback) < overbought threshold)
Short: close crosses below EMA(close, trend lookback) AND (volume filter disabled OR volume > SMA(volume, volume lookback)) AND (RSI filter disabled OR RSI(close, RSI lookback) > oversold threshold)