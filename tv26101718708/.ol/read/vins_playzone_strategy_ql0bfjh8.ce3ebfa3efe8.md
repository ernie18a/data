Calculation: Smoothed price = EMA(price, smoothing length) on chart bars.
Calculation: Fast EMA = EMA of the higher-timeframe EMA of price using a shorter lookback than the slow EMA, then smoothed on chart bars; use the still-forming higher-timeframe bar.
Calculation: Slow EMA = EMA of price on the still-forming higher-timeframe bar, then smoothed on chart bars; its lookback is longer than the fast EMA's.
Calculation: Base EMA = EMA of price on the still-forming higher-timeframe bar, then smoothed on chart bars; its lookback is longer than both fast and slow EMA lookbacks.
Calculation: K = SMA of Stochastic(RSI(price, RSI lookback), stochastic lookback), using the same RSI series for the stochastic high, low, and source.
Calculation: D = SMA of K using a longer smoothing lookback than K's.
Calculation: Bullish regime = the most recent onset of the green zone is more recent than the most recent onset of the red zone; green zone = fast EMA > slow EMA AND smoothed price > fast EMA; red zone = fast EMA < slow EMA AND smoothed price < fast EMA.
Long: green-zone onset AND previous bar was not in the bullish regime OR bullish regime AND K crosses above D AND ((D < oversold threshold AND 4 > signal threshold) OR (D > oversold threshold AND 2 > signal threshold))
Short: red-zone onset AND previous bar was in the bullish regime OR NOT bullish regime AND K crosses below D AND ((D > overbought threshold AND 4 > signal threshold) OR (D < overbought threshold AND 2 > signal threshold))
Exit: long, red-zone onset OR fast EMA < slow EMA
Exit: short, green-zone onset OR fast EMA > slow EMA