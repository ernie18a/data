Calculation: Bullish score(T) = (1 if at least two confirmed pivot highs and lows on T exist and the latest pivot high is greater than the previous pivot high AND the latest pivot low is greater than the previous pivot low, otherwise 0) + (1 if ROC(close from T sampled on chart bars, ROC lookback in chart bars) > 0, otherwise 0) + (1 if close of T's current bar > open of T's current bar, otherwise 0); T bar values may be from the bar still forming
Calculation: Bearish score(T) = (1 if at least two confirmed pivot highs and lows on T exist and the latest pivot high is less than the previous pivot high AND the latest pivot low is less than the previous pivot low, otherwise 0) + (1 if ROC(close from T sampled on chart bars, ROC lookback in chart bars) < 0, otherwise 0) + (1 if close of T's current bar < open of T's current bar, otherwise 0); T bar values may be from the bar still forming
Long: Bullish score(T1) > Bearish score(T1)
Short: Bearish score(T1) > Bullish score(T1)
Long: Bullish score(T2) > Bearish score(T2)
Short: Bearish score(T2) > Bullish score(T2)
Long: Bullish score(T3) > Bearish score(T3)
Short: Bearish score(T3) > Bullish score(T3)
Long: Bullish score(T4) > Bearish score(T4)
Short: Bearish score(T4) > Bullish score(T4)