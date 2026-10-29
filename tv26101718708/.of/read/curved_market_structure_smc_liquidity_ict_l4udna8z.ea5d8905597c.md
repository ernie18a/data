Calculation: Lower smooth curve = double exponential moving average of close, using the curve smoothing length and then half that length rounded, minus the exponential moving average of the close standard deviation over the curve smoothing length multiplied by the curve multiplier
Calculation: Upper smooth curve = double exponential moving average of close, using the curve smoothing length and then half that length rounded, plus the exponential moving average of the close standard deviation over the curve smoothing length multiplied by the curve multiplier
Calculation: Candle body-to-range ratio = absolute(close - open) / (high - low), or 0 when high = low
Long: (low on the previous bar <= previous lower smooth curve OR current low <= current lower smooth curve) AND RSI(14) > 45 AND close > open AND bars since the previous buy signal >= the signal cooldown
Long: close > open AND candle body-to-range ratio >= consolidation threshold
Long: close crosses above the latest confirmed pivot high, using equal left and right pivot lookbacks
Short: (high on the previous bar >= previous upper smooth curve OR current high >= current upper smooth curve) AND RSI(14) < 55 AND close < open AND bars since the previous sell signal >= the signal cooldown
Short: close < open AND candle body-to-range ratio >= consolidation threshold
Short: close crosses below the latest confirmed pivot low, using equal left and right pivot lookbacks