Calculation: Smoothed stochastic K = simple moving average of stochastic %K; stochastic D = simple moving average of smoothed stochastic K.
Calculation: Long setup = close > EMA AND EMA > previous EMA AND absolute value of (close - EMA) <= ATR multiplied by a distance parameter AND minimum of smoothed stochastic K and D is within the long pullback zone, inclusive AND K crosses above D AND MACD histogram > previous MACD histogram AND close > open AND (volume filter disabled OR volume > volume simple moving average multiplied by a volume parameter) AND (trend filter disabled OR ADX >= trend threshold).
Calculation: Short setup = close < EMA AND EMA < previous EMA AND absolute value of (close - EMA) <= ATR multiplied by a distance parameter AND maximum of smoothed stochastic K and D is within the short pullback zone, inclusive AND K crosses below D AND MACD histogram < previous MACD histogram AND close < open AND (volume filter disabled OR volume > volume simple moving average multiplied by a volume parameter) AND (trend filter disabled OR ADX >= trend threshold).
Calculation: Long stop = lowest low over the stop lookback ending on the long-entry bar minus ATR on that bar multiplied by a stop parameter; retain this value until the next entry.
Calculation: Short stop = highest high over the stop lookback ending on the short-entry bar plus ATR on that bar multiplied by a stop parameter; retain this value until the next entry.
Long: EMA > previous EMA.
Short: EMA < previous EMA.
Long: Long setup is true AND previous long setup is false.
Short: Short setup is true AND previous short setup is false.
Exit: long, low <= long stop OR (stochastic exit enabled AND smoothed stochastic K >= upper exit threshold AND K crosses below D).
Exit: short, high >= short stop OR (stochastic exit enabled AND smoothed stochastic K <= lower exit threshold AND K crosses above D).