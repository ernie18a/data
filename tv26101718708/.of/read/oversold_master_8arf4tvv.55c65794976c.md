Calculation: Smoothed RSI = EMA of RSI calculated from close
Calculation: Overbought threshold = adaptive upper band when adaptive bands are enabled; otherwise the selected fixed overbought RSI level
Calculation: Oversold threshold = adaptive lower band when adaptive bands are enabled; otherwise the selected fixed oversold RSI level
Calculation: Adaptive upper band = SMA of smoothed RSI over the band lookback + band multiplier × standard deviation of smoothed RSI over the same lookback
Calculation: Adaptive lower band = SMA of smoothed RSI over the band lookback − band multiplier × standard deviation of smoothed RSI over the same lookback
Long: The prior bar's smoothed RSI was at or below the oversold threshold, followed by the configured number of consecutive closed bars with smoothed RSI above the oversold threshold, and the last completed higher-timeframe close is above its EMA
Short: The prior bar's smoothed RSI was at or above the overbought threshold, followed by the configured number of consecutive closed bars with smoothed RSI below the overbought threshold, and the last completed higher-timeframe close is below its EMA