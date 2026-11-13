Calculation: AdaptiveT3 = RSI of close; len = round(minLen + (maxLen - minLen) * (1 - RSI/100)), with maxLen > minLen, recomputed every bar, so higher RSI gives a shorter len; EMA(x) = recursive EMA with alpha = 2/(len+1) using the current bar's len, seeded with the first value; e1 = EMA(close), e2 = EMA(e1), ..., e6 = EMA(e5); with volume factor v: T3 = (-v^3)*e6 + (3v^2 + 3v^3)*e5 + (-6v^2 - 3v - 3v^3)*e4 + (1 + 3v + v^3 + 3v^2)*e3; T3 cross up = T3 > T3[2] AND T3[1] <= T3[3]; T3 cross down = T3 < T3[2] AND T3[1] >= T3[3]
Calculation: SAR = Parabolic SAR (start, increment, maximum)
Long: AdaptiveT3 cross up (T3 crosses above its value 2 bars earlier) AND close > SAR AND position is flat or short
Short: AdaptiveT3 cross down (T3 crosses below its value 2 bars earlier) AND close <= SAR AND position is flat or long
Exit: long, Short condition is true (close the long and reverse to short)
Exit: short, Long condition is true (close the short and reverse to long)
Exit: long, low <= stop level, where stop level = lowest low over the stop lookback ending at the bar where the Long entry signal occurred (including that bar), fixed for the life of the trade
Exit: short, high >= stop level, where stop level = highest high over the stop lookback ending at the bar where the Short entry signal occurred (including that bar), fixed for the life of the trade