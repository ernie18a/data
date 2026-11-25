Calculation: Chart MACD histogram = MACD histogram(close, fast lookback, slow lookback, signal lookback, chart bars, current bar still forming)
Calculation: T1 MACD histogram = MACD histogram(close, fast lookback, slow lookback, signal lookback, on chart bars using the still-forming T1 bar containing each chart bar time); T1, T2, and T3 are successively higher timeframes than the chart timeframe
Calculation: T2 MACD histogram = MACD histogram(close, fast lookback, slow lookback, signal lookback, on chart bars using the still-forming T2 bar containing each chart bar time)
Calculation: T3 MACD histogram = MACD histogram(close, fast lookback, slow lookback, signal lookback, on chart bars using the still-forming T3 bar containing each chart bar time)
Calculation: Trend EMA = EMA(close, lookback, chart bars, current bar still forming)
Long: close > Trend EMA AND Chart MACD histogram > 0 AND T1 MACD histogram > 0 AND T2 MACD histogram < 0 AND T3 MACD histogram < 0
Short: close < Trend EMA AND Chart MACD histogram < 0 AND T1 MACD histogram < 0 AND T2 MACD histogram < 0 AND T3 MACD histogram < 0