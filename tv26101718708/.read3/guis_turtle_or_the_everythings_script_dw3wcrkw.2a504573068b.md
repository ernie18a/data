Calculation: Up streak = consecutive count of close > close[comparison lookback], reset when the condition is false
Calculation: Down streak = consecutive count of close < close[comparison lookback], reset when the condition is false
Calculation: Up marker count = Up streak - valuewhen(Up streak < Up streak[previous bar], Up streak, second-most-recent occurrence)
Calculation: Down marker count = Down streak - valuewhen(Down streak < Down streak[previous bar], Down streak, second-most-recent occurrence)
Calculation: Bars since bullish comparison = bars since(close > close[comparison lookback])
Calculation: Bars since bearish comparison = bars since(close < close[comparison lookback])
Calculation: Previous T1 VWAP = sum(((high + low) / 2) * volume over chart bars in the last completed T1 period) / sum(volume over chart bars in the same period)
Long: Up marker count >= lower count parameter AND Up marker count <= upper count parameter
Long: close < close[comparison lookback] AND (Bars since bullish comparison = setup count parameter OR Bars since bullish comparison = overshoot count parameter one OR Bars since bullish comparison = overshoot count parameter two OR Bars since bullish comparison = overshoot count parameter three OR Bars since bullish comparison = overshoot count parameter four)
Long: high >= highest(high, pivot left lookback)
Long: low[right lookback + one bar] <= lowest(low, left lookback + right lookback + one bar)[right lookback + one bar]
Long: close > Previous T1 VWAP
Long: ParabolicSAR(initial step parameter, step increment parameter, maximum step parameter) != 0 AND close >= ParabolicSAR(initial step parameter, step increment parameter, maximum step parameter)
Long: high > highest(high, Turtle lookback)[previous bar]
Short: Down marker count >= lower count parameter AND Down marker count <= upper count parameter
Short: close > close[comparison lookback] AND (Bars since bearish comparison = setup count parameter OR Bars since bearish comparison = overshoot count parameter one OR Bars since bearish comparison = overshoot count parameter two OR Bars since bearish comparison = overshoot count parameter three OR Bars since bearish comparison = overshoot count parameter four)
Short: low <= lowest(low, pivot left lookback)
Short: high[right lookback + one bar] >= highest(high, left lookback + right lookback + one bar)[right lookback + one bar]
Short: close <= Previous T1 VWAP
Short: ParabolicSAR(initial step parameter, step increment parameter, maximum step parameter) != 0 AND close <= ParabolicSAR(initial step parameter, step increment parameter, maximum step parameter)
Short: low < lowest(low, Turtle lookback)[previous bar]