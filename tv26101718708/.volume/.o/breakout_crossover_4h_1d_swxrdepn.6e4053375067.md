Calculation: Daily-bar open = open of the daily bar still forming
Calculation: Comparison-timeframe close = close of the comparison-timeframe bar still forming
Calculation: Latest confirmed fractal high = center high of the latest five-bar sequence whose center high exceeds the other four highs; update when confirmed and otherwise retain
Calculation: Latest confirmed fractal low = center low of the latest five-bar sequence whose center low is below the other four lows; update when confirmed and otherwise retain
Calculation: Bullish candle pattern = enabled bullish pin bar OR enabled piercing line OR enabled bullish harami OR enabled bullish engulfing OR enabled close crossover above latest confirmed fractal high
Calculation: Bearish candle pattern = enabled bearish pin bar OR enabled dark cloud cover OR enabled bearish harami OR enabled bearish engulfing OR enabled close crossunder below latest confirmed fractal low
Long: datetime is before 2021-08-01 08:18 AND (comparison-timeframe close crosses above daily-bar open OR (close > daily-bar open AND bullish candle pattern AND position is flat))
Short: datetime is before 2021-08-01 08:18 AND (comparison-timeframe close crosses below daily-bar open OR (close < daily-bar open AND bearish candle pattern AND position is flat))
Exit: Long, datetime is before 2021-08-01 08:18 AND (comparison-timeframe close crosses below daily-bar open OR (close < daily-bar open AND bearish candle pattern AND position is flat))
Exit: Short, datetime is before 2021-08-01 08:18 AND (comparison-timeframe close crosses above daily-bar open OR (close > daily-bar open AND bullish candle pattern AND position is flat))