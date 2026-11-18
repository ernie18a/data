Calculation: short-term SMA = SMA(close, shorter lookback)
Calculation: long-term SMA = SMA(close, longer lookback)
Calculation: lower Bollinger Band = SMA(close, Bollinger lookback) - Bollinger multiplier * standard deviation(close, Bollinger lookback)
Long: short-term SMA > long-term SMA AND close crosses above lower Bollinger Band
Short: short-term SMA < long-term SMA AND close crosses below lower Bollinger Band
Exit: Long, after long-term SMA crosses above short-term SMA, high reaches entry price plus an activation-distance parameter in ticks, then low reaches the highest high since activation minus a trailing-offset parameter in ticks
Exit: Short, after short-term SMA crosses above long-term SMA, low reaches entry price minus an activation-distance parameter in ticks, then high reaches the lowest low since activation plus a trailing-offset parameter in ticks