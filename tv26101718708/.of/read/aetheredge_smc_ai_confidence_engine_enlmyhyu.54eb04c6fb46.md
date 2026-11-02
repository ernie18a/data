Calculation: Confirmed swing high or low = a pivot high or low with the same number of chart bars on each side; it becomes available only after the right-hand bars have completed. Use the most recently confirmed pivot of each kind.
Calculation: Structure direction = the direction of the most recent structure break, initially neutral; an upward break occurs when close > the latest confirmed swing high AND the previous close <= that same swing high; a downward break occurs when close < the latest confirmed swing low AND the previous close >= that same swing low. If both occur on the same bar, the direction is downward.
Calculation: Higher-timeframe EMA direction = compare the short-period EMA of close with the long-period EMA of close on each of three higher timeframes. Historical chart bars use the last completed higher-timeframe bar; a realtime chart bar uses the higher-timeframe bar still forming.
Long: Structure direction = upward
Short: Structure direction = downward
Long: Short-period higher-timeframe EMA > long-period higher-timeframe EMA
Short: Short-period higher-timeframe EMA < long-period higher-timeframe EMA
Long: Close > open AND absolute value of close minus open / ATR > displacement threshold AND volume z-score > volume threshold AND close > latest confirmed swing high AND previous close <= that same swing high AND at least one preceding candle within the order-block lookback has close < open
Short: Close < open AND absolute value of close minus open / ATR > displacement threshold AND volume z-score > volume threshold AND close < latest confirmed swing low AND previous close >= that same swing low AND at least one preceding candle within the order-block lookback has close > open
Long: Low > high two bars earlier AND low minus that high > gap-size threshold × ATR
Short: High < low two bars earlier AND that low minus high > gap-size threshold × ATR
Long: Low < latest confirmed swing low minus sweep tolerance × ATR AND close > that swing low
Short: High > latest confirmed swing high plus sweep tolerance × ATR AND close < that swing high