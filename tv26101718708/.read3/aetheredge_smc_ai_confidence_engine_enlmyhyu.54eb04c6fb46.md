Calculation: last pivot high = most recent non-NA PivotHigh(high, pivot length, pivot length)
Calculation: last pivot low = most recent non-NA PivotLow(low, pivot length, pivot length)
Calculation: bullish break = close > last pivot high AND close[1] <= last pivot high
Calculation: bearish break = close < last pivot low AND close[1] >= last pivot low
Calculation: body-to-ATR ratio = ABS(close - open) / ATR(ATR length)
Calculation: volume z-score = (volume - SMA(volume, volume length)) / STDEV(volume, volume length)
Calculation: trend sign(T) = SIGN(EMA(close, shorter EMA length, T, last completed bar) - EMA(close, longer EMA length, T, last completed bar))
Calculation: trend direction = IF(bearish break, -1, IF(bullish break, 1, trend direction[1]))
Long: bullish break
Short: bearish break
Long: close > open AND body-to-ATR ratio > body-to-ATR threshold AND volume z-score > volume z-score threshold AND bullish break AND close[i] < open[i] for some i from 1 to OB search window
Short: close < open AND body-to-ATR ratio > body-to-ATR threshold AND volume z-score > volume z-score threshold AND bearish break AND close[i] > open[i] for some i from 1 to OB search window
Long: low > high[2] AND low - high[2] > FVG minimum size * ATR(ATR length)
Short: high < low[2] AND low[2] - high > FVG minimum size * ATR(ATR length)
Short: high > last pivot high + sweep tolerance * ATR(ATR length) AND close < last pivot high
Long: low < last pivot low - sweep tolerance * ATR(ATR length) AND close > last pivot low
Long: trend direction > 0
Short: trend direction < 0
Long: trend sign(T1) > 0
Long: trend sign(T2) > 0
Long: trend sign(T3) > 0
Short: trend sign(T1) < 0
Short: trend sign(T2) < 0
Short: trend sign(T3) < 0
Long: trend sign(T1) + trend sign(T2) + trend sign(T3) > 0
Short: trend sign(T1) + trend sign(T2) + trend sign(T3) < 0