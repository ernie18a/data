Calculation: Pivot high = a high greater than the highs of the same number of bars before and after it; confirmed after those following bars complete.
Calculation: Pivot low = a low lower than the lows of the same number of bars before and after it; confirmed after those following bars complete.
Calculation: Bullish BOS = a newly confirmed pivot high is higher than the preceding confirmed pivot high.
Calculation: Bearish BOS = a newly confirmed pivot low is lower than the preceding confirmed pivot low.
Long: Bullish BOS OR low[1] < lowest low of the preceding sweep lookback bars AND close > that low AND close[1] < that low OR low > high[2] AND (low - high[2]) / close × 100 ≥ the minimum gap percentage
Short: Bearish BOS OR high[1] > highest high of the preceding sweep lookback bars AND close < that high AND close[1] > that high OR low[2] > high AND (low[2] - high) / close × 100 ≥ the minimum gap percentage