Calculation: candle top = max(close, open)
Calculation: candle bottom = min(close, open)
Calculation: state = high if high[swing lookback] > Highest(high, swing lookback), else low if low[swing lookback] < Lowest(low, swing lookback), else state[1]
Calculation: last swing high = high[swing lookback] if state is high and state[1] is not high, else last swing high[1]
Calculation: last swing low = low[swing lookback] if state is low and state[1] is not low, else last swing low[1]
Calculation: bullish OB = candle with the lowest candle bottom among bars after the bar of the last swing high and before the current bar; OB top = its candle top, OB bottom = its candle bottom
Calculation: bearish OB = candle with the highest candle top among bars after the bar of the last swing low and before the current bar; OB top = its candle top, OB bottom = its candle bottom
Long: SMA(close, shorter lookback) > SMA(close, longer lookback)
Short: SMA(close, shorter lookback) < SMA(close, longer lookback)
Long: SMA(close, shorter lookback of T1, T1 bars, bar still forming) > SMA(close, longer lookback of T1, T1 bars, bar still forming)
Short: SMA(close, shorter lookback of T1, T1 bars, bar still forming) < SMA(close, longer lookback of T1, T1 bars, bar still forming)
Long: SMA(close, shorter lookback of T2, T2 bars, bar still forming) > SMA(close, longer lookback of T2, T2 bars, bar still forming)
Short: SMA(close, shorter lookback of T2, T2 bars, bar still forming) < SMA(close, longer lookback of T2, T2 bars, bar still forming)
Long: bars before the last bar <= window AND close crosses above last swing high for the first time since that swing high was set
Short: bars before the last bar <= window AND close crosses below last swing low for the first time since that swing low was set
Short: bars before the last bar <= window AND last swing high is above the bottom and below the top of a bullish OB among the bullish count newest remaining bullish OBs, where that OB was broken on an earlier bar (candle bottom below OB bottom) and close has not exceeded its top since then including this bar, AND this was false on the previous bar
Long: bars before the last bar <= window AND last swing low is above the bottom and below the top of a bearish OB among the bearish count newest remaining bearish OBs, where that OB was broken on an earlier bar (candle top above OB top) and close has not gone below its bottom since then including this bar, AND this was false on the previous bar
Short: high exceeds killzone high of the most recent session for the first time since that killzone high was set
Long: low falls below killzone low of the most recent session for the first time since that killzone low was set