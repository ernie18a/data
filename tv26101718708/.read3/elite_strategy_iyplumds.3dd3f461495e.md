Calculation: MTF trend(T) = bullish when the chart-bar value from T's still-forming bar has close > EMA(close, longer lookback, T); bearish when close < that EMA; neutral otherwise
Calculation: Bullish MTF count = number of T1–T6 with bullish MTF trend
Calculation: Bearish MTF count = number of T1–T6 with bearish MTF trend
Long: Supertrend(multiplier, ATR lookback) direction changes from bearish to bullish AND (MTF filter disabled OR Bullish MTF count >= minimum bullish count) AND selected session filter permits the chart bar AND trade direction permits long
Short: Supertrend(multiplier, ATR lookback) direction changes from bullish to bearish AND (MTF filter disabled OR Bearish MTF count >= minimum bearish count) AND selected session filter permits the chart bar AND trade direction permits short
Long: close > VWAP
Short: close <= VWAP
Long: RSI(close, lookback) > RSI threshold
Short: RSI(close, lookback) <= RSI threshold
Long: MACD line(close, shorter EMA lookback, longer EMA lookback) > 0
Short: MACD line(close, shorter EMA lookback, longer EMA lookback) <= 0
Long: MTF trend(T1) is bullish OR MTF trend(T2) is bullish OR MTF trend(T3) is bullish OR MTF trend(T4) is bullish OR MTF trend(T5) is bullish OR MTF trend(T6) is bullish
Short: MTF trend(T1) is bearish OR MTF trend(T2) is bearish OR MTF trend(T3) is bearish OR MTF trend(T4) is bearish OR MTF trend(T5) is bearish OR MTF trend(T6) is bearish
Long: Bullish MTF count > Bearish MTF count
Short: Bullish MTF count <= Bearish MTF count