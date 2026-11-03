Calculation: Smoothed stochastic %K = SMA of stochastic %K; stochastic %D = SMA of smoothed stochastic %K.
Calculation: Regime EMA rising or falling = its current value is respectively greater or less than every value in its preceding lookback window.
Long: Shorter-period EMA of close > longer-period EMA of close.
Short: Shorter-period EMA of close <= longer-period EMA of close.
Long: Close > regime EMA AND (strict regime disabled OR regime EMA rising).
Short: Close < regime EMA AND (strict regime disabled OR regime EMA falling).
Long: RSI <= oversold threshold OR (RSI > midpoint AND RSI < overbought threshold).
Short: (RSI > oversold threshold AND RSI <= midpoint) OR RSI >= overbought threshold.
Long: Smoothed stochastic %K > stochastic %D AND smoothed stochastic %K < upper threshold.
Short: Smoothed stochastic %K < stochastic %D AND smoothed stochastic %K > lower threshold.
Long: MACD histogram > zero AND MACD histogram > previous bar's MACD histogram.
Short: MACD histogram < zero AND MACD histogram < previous bar's MACD histogram.
Long: Close > session VWAP of typical price.
Short: Close <= session VWAP of typical price.