Calculation: bias(T) = bullish when close(T) > EMA(close, fast lookback, T) > EMA(close, longer lookback, T); bearish when close(T) < EMA(close, fast lookback, T) < EMA(close, longer lookback, T); otherwise flat; evaluated on chart bars using the latest available T value (the still-forming T bar in real time, the last completed T bar historically), with the longer lookback greater than the fast lookback
Long: bias(T1) is bullish
Long: bias(T2) is bullish
Long: bias(T3) is bullish
Long: bias(T4) is bullish
Long: bias(T5) is bullish
Short: bias(T1) is bearish
Short: bias(T2) is bearish
Short: bias(T3) is bearish
Short: bias(T4) is bearish
Short: bias(T5) is bearish
Long: the bullish bias count among T1, T2, T3, T4, and T5 is greater than the bearish bias count among them
Short: the bearish bias count among T1, T2, T3, T4, and T5 is greater than the bullish bias count among them
Long: bias(T_alert) becomes bullish from a non-bullish value
Short: bias(T_alert) becomes bearish from a non-bearish value