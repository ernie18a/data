Calculation: anchor high = highest(high on chart bars in the anchor window for each day)
Calculation: anchor low = lowest(low on chart bars in the anchor window for each day)
Calculation: daily breakout bias = direction of the latest valid breakout close outside the completed anchor range; reset each day
Long: after anchor range completion, during the breakout window with breakout dots enabled, close > anchor high AND no earlier close above anchor high that day
Short: after anchor range completion, during the breakout window with breakout dots enabled, close < anchor low AND no earlier close below anchor low that day
Long: with bias text enabled, daily breakout bias is bullish
Short: with bias text enabled, daily breakout bias is bearish
Long: after anchor range completion, during the breakout window with FVGs enabled, daily breakout bias is bullish AND low > high[2]
Short: after anchor range completion, during the breakout window with FVGs enabled, daily breakout bias is bearish AND high < low[2]