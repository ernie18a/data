Calculation: Initial risk distance = initial-stop ATR multiple × ATR of the higher timeframe
Calculation: Initial stop = entry price − initial risk distance
Calculation: One-R price = entry price + initial risk distance
Calculation: Highest high = highest high since entry, updated with each completed higher-timeframe bar
Calculation: Chandelier stop = highest high − trailing ATR multiple × ATR of the higher timeframe
Calculation: Active stop = initial stop until trailing activates; after activation, update to the maximum of the prior active stop, entry price, and chandelier stop
Long: Flat AND (at each completed higher-timeframe bar, close > EMA AND RSI >= 50 AND RSI <= 70 AND volume > volume SMA) OR (while the higher-timeframe bar is forming, close > EMA AND RSI >= 50 AND RSI <= 70 AND volume > volume SMA)
Short: At each completed higher-timeframe bar, close < EMA AND RSI >= 30 AND RSI <= 50 AND volume > volume SMA
Exit: Long, at each completed higher-timeframe bar, low <= active stop