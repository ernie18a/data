Calculation: Exponential moving averages = fast EMA and slow EMA of close; fast length is shorter than slow length.
Calculation: ADX = +DI, −DI, and ADX from the directional movement index.
Calculation: MACD histogram = MACD line minus its signal line, using a shorter fast length and longer slow length.
Calculation: Bollinger Bands = middle band and upper/lower bands from close; width = (upper band − lower band) / middle band.
Calculation: ATR stop = for long, current low minus ATR × multiplier, raised to at least the prior ATR stop when current open is above that prior stop; for short, current high plus ATR × multiplier, lowered to at most the prior ATR stop when current open is below that prior stop.
Calculation: Donchian upper/lower = highest high / lowest low over the lookback.
Long: fast EMA > slow EMA AND slow EMA > prior slow EMA
Long: +DI > −DI AND ADX > threshold
Long: Parabolic SAR < close
Long: MACD histogram > 0
Long: volume > volume SMA × volume factor
Long: Position allows longs AND fast EMA > slow EMA AND slow EMA > prior slow EMA AND +DI > −DI AND ADX > threshold AND Parabolic SAR < close AND MACD histogram > 0 AND volume > volume SMA × volume factor AND (no open position OR position is short OR close < last entry price × (1 − better-price threshold))
Long: Position allows longs AND NOT (+DI < −DI AND ADX > threshold) AND low crosses below the lower Bollinger Band AND fast EMA > slow EMA AND Bollinger Band width > new-position width threshold AND (no open position OR position is short OR close < last entry price × (1 − better-price threshold))
Long: Position allows longs AND NOT (+DI < −DI AND ADX > threshold) AND low crosses below the lower Bollinger Band AND fast EMA > slow EMA AND Bollinger Band width > pyramiding width threshold AND position is long AND close < last entry price × (1 − better-price threshold)
Short: fast EMA < slow EMA AND slow EMA < prior slow EMA
Short: +DI < −DI AND ADX > threshold
Short: Parabolic SAR > close
Short: MACD histogram < 0
Short: volume > volume SMA × volume factor
Short: Position allows shorts AND fast EMA < slow EMA AND slow EMA < prior slow EMA AND +DI < −DI AND ADX > threshold AND Parabolic SAR > close AND MACD histogram < 0 AND volume > volume SMA × volume factor AND (no open position OR position is long OR close > last entry price × (1 + better-price threshold))
Short: Position allows shorts AND NOT (+DI > −DI AND ADX > threshold) AND high crosses above the upper Bollinger Band AND fast EMA < slow EMA AND Bollinger Band width > new-position width threshold AND (no open position OR position is long OR close > last entry price × (1 + better-price threshold))
Short: Position allows shorts AND NOT (+DI > −DI AND ADX > threshold) AND high crosses above the upper Bollinger Band AND fast EMA < slow EMA AND Bollinger Band width > pyramiding width threshold AND position is short AND close > last entry price × (1 + better-price threshold)
Exit: long, low <= long stop price OR (trailing disabled AND high >= long take-profit price) OR (trailing enabled AND high reaches long take-profit activation price AND low reaches the trailing stop)
Exit: short, high >= short stop price OR (trailing disabled AND low <= short take-profit price) OR (trailing enabled AND low reaches short take-profit activation price AND high reaches the trailing stop)