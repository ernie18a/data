Calculation: Breakout high = highest high over a lookback ending on the previous bar; breakout low = lowest low over the same lookback ending on the previous bar.
Calculation: Bullish breakout = close > breakout high + ATR × breakout buffer; bearish breakout = close < breakout low - ATR × breakout buffer.
Calculation: Bullish retest = bars since the latest bullish breakout began > 0 AND bars since it began <= retest window AND low <= breakout high recorded when it began + current ATR × retest tolerance AND close >= that recorded breakout high AND close > open. A breakout begins when the bullish breakout condition is true and was false on the preceding bar.
Calculation: Bearish retest = bars since the latest bearish breakout began > 0 AND bars since it began <= retest window AND high >= breakout low recorded when it began - current ATR × retest tolerance AND close <= that recorded breakout low AND close < open. A breakout begins when the bearish breakout condition is true and was false on the preceding bar.
Calculation: Confirmed price pivot = a pivot high or low with the same number of bars on each side; evaluate it on the bar that confirms it and associate it with RSI on the pivot bar.
Long: Shortest EMA > short EMA AND short EMA > long EMA AND long EMA > longest EMA.
Short: Shortest EMA < short EMA AND short EMA < long EMA AND long EMA < longest EMA.
Long: RSI >= bullish RSI threshold.
Short: RSI <= bearish RSI threshold.
Long: MACD line > MACD signal line AND MACD histogram > 0.
Short: MACD line < MACD signal line AND MACD histogram < 0.
Long: +DI > -DI.
Short: +DI <= -DI.
Long: On a higher timeframe's last completed bar, close > short EMA AND shortest EMA > short EMA AND RSI > RSI midpoint.
Short: On a higher timeframe's last completed bar, close < short EMA AND shortest EMA < short EMA AND RSI < RSI midpoint.
Long: A price pivot low is confirmed AND its low < the preceding confirmed pivot low AND its RSI > the RSI at that preceding pivot.
Short: A price pivot high is confirmed AND its high > the preceding confirmed pivot high AND its RSI < the RSI at that preceding pivot.
Long: Bullish retest is true AND bullish retest was false on the preceding bar.
Short: Bearish retest is true AND bearish retest was false on the preceding bar.