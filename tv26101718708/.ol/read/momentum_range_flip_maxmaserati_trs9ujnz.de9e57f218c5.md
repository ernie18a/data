Calculation: Active range top = highest high from the anchor bar through the current bar
Calculation: Active range bottom = lowest low from the anchor bar through the current bar
Long: (close > high[1] OR close < low[1]) AND close >= open OR (close[1] > high[2] AND close <= high[1] AND close >= low[1] AND close[1] >= open[1])
Short: (close > high[1] OR close < low[1]) AND close < open OR (close[1] < low[2] AND close <= high[1] AND close >= low[1] AND close[1] < open[1])
Exit: Long, close > active range top OR close < active range bottom
Exit: Short, close > active range top OR close < active range bottom