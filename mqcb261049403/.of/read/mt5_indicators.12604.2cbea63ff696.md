Calculation: Rolling high = highest high over the lookback window ending on the current chart bar
Calculation: Rolling low = lowest low over the lookback window ending on the current chart bar
Calculation: High moving average = moving average of high over the same lookback window
Calculation: Low moving average = moving average of low over the same lookback window
Calculation: Running maximum of rolling lows = maximum rolling low since the most recent bullish transition; reset to the current rolling low on that transition
Calculation: Running minimum of rolling highs = minimum rolling high since the most recent bearish transition; reset to the current rolling high on that transition
Long: Low moving average > running minimum of rolling highs AND current close > previous chart bar's high
Short: High moving average < running maximum of rolling lows AND current close < previous chart bar's low
Exit: long, High moving average < running maximum of rolling lows AND current close < previous chart bar's low
Exit: short, Low moving average > running minimum of rolling highs AND current close > previous chart bar's high