Calculation: ATR = Average True Range over the SuperTrend length
Calculation: Center = WMA(close*volume, SuperTrend length) / WMA(volume, SuperTrend length)
Calculation: Upper = Center + factor*ATR; Lower = Center - factor*ATR; then ratchet: Lower = Lower if (Lower > previous bar's Lower OR previous close < previous bar's Lower) else previous bar's Lower; Upper = Upper if (Upper < previous bar's Upper OR previous close > previous bar's Upper) else previous bar's Upper (previous values are the ratcheted ones)
Calculation: Dir (-1 = bullish, 1 = bearish) = 1 if previous ATR unavailable; else if previous SuperTrend equals previous Upper then (-1 if close > Upper else 1); else (1 if close < Lower else -1). SuperTrend = Lower if Dir == -1 else Upper
Calculation: PriceMA = WMA(close, short lookback); STMA = WMA(SuperTrend, long lookback), the lookback being longer than PriceMA's
Calculation: KNN = k-nearest-neighbor score at the current bar. Points are the SuperTrend values of the last n bars, including the current one (n >= k). Each point's label is 1 if PriceMA > STMA on that bar, else 0. Pick the k points with the smallest absolute distance to the current SuperTrend. Weight each by 1/(distance+1e-6). KNN = weighted average of their labels. KNN == 1 only when all k labels are 1 (bullish); KNN == 0 only when all k labels are 0 (bearish); any other value is neutral
Long: KNN == 1 AND (previous bar's KNN != 1 OR (Dir == -1 AND previous bar's Dir == 1))
Short: KNN == 0 AND (previous bar's KNN != 0 OR (Dir == 1 AND previous bar's Dir == -1))
Exit: long, NOT(Dir == -1 AND KNN == 1) AND NOT(Dir == 1 AND KNN == 0) AND low <= SuperTrend - factor*ATR
Exit: short, NOT(Dir == -1 AND KNN == 1) AND NOT(Dir == 1 AND KNN == 0) AND high >= SuperTrend + factor*ATR