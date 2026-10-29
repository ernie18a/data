Calculation: MACD histogram divergence = at a cross of the histogram through zero, compare the completed histogram lobe with the previous lobe of the same sign: bullish when the current negative lobe’s trough is higher and its associated close is lower; bearish when the current positive lobe’s peak is lower and its associated close is higher. Associate each lobe’s extreme close with the bar where its histogram extreme is first reached.
Calculation: Fast EMA = EMA of close on a lower timeframe, using the lower-timeframe value sampled for the chart bar.
Calculation: Slow EMA = EMA of close on the chart timeframe.
Calculation: Filter EMA = EMA of close on a higher timeframe, using the last completed bar.
Calculation: Long stop = the greater of the prior long stop and the lowest low over the lookback multiplied by one minus the long stop fraction.
Calculation: Long target = the greater of the prior long target and entry price plus the distance from entry price to long stop multiplied by the profit multiple.
Calculation: Short stop = the lesser of the prior short stop and the highest high over the lookback multiplied by one plus the short stop fraction.
Calculation: Short target = the lesser of the prior short target and entry price minus the distance from short stop to entry price multiplied by the profit multiple.
Long: bullish MACD histogram divergence AND fast EMA > slow EMA AND fast EMA > filter EMA AND flat position
Short: bearish MACD histogram divergence AND fast EMA < slow EMA AND fast EMA < filter EMA AND flat position
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target