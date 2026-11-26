Calculation: EMA_1 = EMA(close, lookback 1)
Calculation: EMA_2 = EMA(close, lookback 2)
Calculation: EMA_3 = EMA(close, lookback 3)
Calculation: ST = direction of Supertrend(factor, ATR period, T1, last completed bar)
Calculation: ALIGN_UP = close is above EMA_1 AND close is above EMA_2 AND close is above EMA_3
Calculation: ALIGN_DOWN = close is below EMA_1 AND close is below EMA_2 AND close is below EMA_3
Long: close crosses above EMA_1
Long: close crosses above EMA_2
Long: close crosses above EMA_3
Short: close crosses below EMA_1
Short: close crosses below EMA_2
Short: close crosses below EMA_3
Long: ST is bullish AND ST[1] is not bullish
Short: ST is bearish AND ST[1] is not bearish
Long: ST is bullish
Short: ST is bearish
Long: ALIGN_UP AND NOT ALIGN_UP[1]
Short: ALIGN_DOWN AND NOT ALIGN_DOWN[1]
Long: ALIGN_UP
Short: ALIGN_DOWN
Long: close is above EMA_1
Long: close is above EMA_2
Long: close is above EMA_3
Short: close is below EMA_1
Short: close is below EMA_2
Short: close is below EMA_3