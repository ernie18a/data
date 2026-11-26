Calculation: Buy score = floor(100 * bullish comparison count / total comparison count), comparing each of open, high, low, (high + low) / 2, (high + low + close) / 3, and (high + low + 2 * close) / 4 on the still-forming bar with the same value on the last completed bar of every configured timeframe except the largest; calculate at each timer update; bullish means current > last completed
Calculation: Sell score = floor(100 * bearish comparison count / total comparison count), using the same comparisons as Buy score; bearish means current <= last completed
Long: Buy score > opening threshold
Short: Sell score > opening threshold
Exit: Long, Buy score < closing threshold
Exit: Short, Sell score < closing threshold