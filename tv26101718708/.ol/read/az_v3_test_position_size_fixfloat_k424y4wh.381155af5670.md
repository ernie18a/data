Calculation: Smoothed price = EMA of the selected source using the smoothing period
Calculation: Fast EMA = EMA of smoothed price using the shorter EMA period
Calculation: Slow EMA = EMA of smoothed price using the longer EMA period
Calculation: Stochastic RSI K = smoothed stochastic of RSI; Stochastic RSI D = smoothed K
Calculation: Green = fast EMA > slow EMA AND smoothed price > fast EMA
Calculation: Red = fast EMA < slow EMA AND smoothed price < fast EMA
Long: Green AND no open position
Long: Green AND NOT previous Green AND bearish on the previous bar
Long: bullish AND K crosses above D AND D is not at the oversold threshold, subject to the configured signal threshold
Short: bearish AND K crosses below D AND D is above the overbought threshold, subject to the configured signal threshold
Exit: Long, Red AND NOT previous Red
Exit: Long, bar low < the lowest low of the 11 bars before entry