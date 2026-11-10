Long: Williams %R > pivot threshold
Short: Williams %R < pivot threshold
Long: Williams %R >= overbought threshold AND Williams %R > oversold threshold
Short: Williams %R < overbought threshold
Long: Accumulation/distribution using volume on the forming bar of a monitored timeframe > its value a lookback ago + DeMarker on that forming bar + ATR on that forming bar
Short: Accumulation/distribution using volume on the forming bar of a monitored timeframe < its value a lookback ago - DeMarker on that forming bar - ATR on that forming bar
Long: Williams %R > pivot threshold AND Williams %R >= overbought threshold AND Williams %R > oversold threshold AND accumulation/distribution using volume on the forming bar of every monitored timeframe > its value a lookback ago + DeMarker on that forming bar + ATR on that forming bar
Short: Williams %R < pivot threshold AND Williams %R < overbought threshold AND accumulation/distribution using volume on the forming bar of every monitored timeframe < its value a lookback ago - DeMarker on that forming bar - ATR on that forming bar
Calculation: Monitored timeframes = chart timeframe and timeframes higher and lower than the chart timeframe; use each monitored timeframe's bar still forming. The accumulation/distribution lookback, DeMarker period, and ATR period are equal.