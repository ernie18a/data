Calculation: Adaptive T3 = T3(close, round(minimum T3 length + (maximum T3 length - minimum T3 length) * (1 - RSI(close, RSI lookback) / 100)), T3 volume factor)
Calculation: SAR = Parabolic SAR(start, increment, maximum)
Long: Adaptive T3 crosses above its value 2 bars ago AND close > SAR AND position is flat or short
Short: Adaptive T3 crosses below its value 2 bars ago AND close <= SAR AND position is flat or long
Long: Adaptive T3 > its value 2 bars ago
Short: Adaptive T3 <= its value 2 bars ago
Long: close > SAR AND close 1 bar ago > SAR 1 bar ago
Short: close <= SAR AND close 1 bar ago <= SAR 1 bar ago
Exit: Long, low <= the lowest low over the stop lookback on the long-entry signal bar
Exit: Short, high >= the highest high over the stop lookback on the short-entry signal bar