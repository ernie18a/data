Calculation: Volume average = simple moving average of volume, replacing missing volume with zero.
Calculation: Volume available = volume is present AND volume > 0 AND volume average > 0.
Calculation: Bullish alignment = close > EMA of close AND RSI of close > 50 AND (volume available = false OR (volume > volume average AND close > open)).
Calculation: Bearish alignment = (close <= EMA of close OR EMA is unavailable) AND (RSI of close <= 50 OR RSI is unavailable) AND (volume available = false OR (volume > volume average AND close <= open)).
Long: close > EMA of close
Short: close <= EMA of close OR EMA is unavailable
Long: RSI of close > 50
Short: RSI of close <= 50 OR RSI is unavailable
Long: volume available = true AND volume > volume average AND close > open
Short: volume available = true AND volume > volume average AND close <= open
Long: bullish alignment = true
Short: bearish alignment = true
Long: bullish alignment = true AND previous bar bullish alignment = false
Short: bearish alignment = true AND previous bar bearish alignment = false