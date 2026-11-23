Calculation: Leg = bearish if high[swing length] > highest(high, swing length); bullish if low[swing length] < lowest(low, swing length); otherwise Leg[1]
Calculation: Swing top = high[swing length], and Swing top bar = bar - swing length, both set on each bar where Leg is bearish and Leg[1] is not bearish
Calculation: Swing bottom = low[swing length], and Swing bottom bar = bar - swing length, both set on each bar where Leg is bullish and Leg[1] is not bullish
Calculation: Bullish OB = top high and bottom low of the bar with the lowest low among bars strictly between Swing top bar and the current bar, set on each bar where close crosses above Swing top for the first time since Swing top was set; discarded on a bar where close is above its top and min(close, open) was below its bottom on an earlier bar
Calculation: Bearish OB = top high and bottom low of the bar with the highest high among bars strictly between Swing bottom bar and the current bar, set on each bar where close crosses below Swing bottom for the first time since Swing bottom was set; discarded on a bar where close is below its bottom and max(close, open) was above its top on an earlier bar
Calculation: Bullish polarity = 1 if Swing top lies strictly between the bottom and top of one of the most recent bull count stored Bullish OBs, provided min(close, open) was below its bottom on an earlier bar; otherwise 0
Calculation: Bearish polarity = 1 if Swing bottom lies strictly between the bottom and top of one of the most recent bear count stored Bearish OBs, provided max(close, open) was above its top on an earlier bar; otherwise 0
Long: close crosses above Pivot Point(high, low, close, T1, last completed bar) AND chart timeframe <= T1
Short: close crosses below Pivot Point(high, low, close, T1, last completed bar) AND chart timeframe <= T1
Long: close crosses above Swing top for the first time since Swing top was set
Short: close crosses below Swing bottom for the first time since Swing bottom was set
Short: min(close, open) crosses below the bottom of a Bullish OB for the first time since that Bullish OB was set
Long: max(close, open) crosses above the top of a Bearish OB for the first time since that Bearish OB was set
Short: Bullish polarity crosses above 0
Long: Bearish polarity crosses above 0
Long: close > open AND close[1] > open[1] AND close[2] > open[2] AND low > high[2] AND close[1] > high[2] AND low - high[2] >= threshold ratio * SMA(high - low, threshold lookback)
Short: close < open AND close[1] < open[1] AND close[2] < open[2] AND high < low[2] AND close[1] < low[2] AND low[2] - high >= threshold ratio * SMA(high - low, threshold lookback)