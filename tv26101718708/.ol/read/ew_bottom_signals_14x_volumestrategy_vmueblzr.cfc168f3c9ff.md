Calculation: Short-term moving average = simple moving average of close over a shorter lookback than the long-term moving average
Calculation: Long-term moving average = simple moving average of close over a longer lookback than the short-term moving average
Calculation: Volume average = simple moving average of volume
Calculation: Candle body size = abs(close - open)
Calculation: Candle wick size = high - low - candle body size
Calculation: Confirmed swing high = the high at the center of a symmetric lookback window that equals the highest high in that window; recognize it after the bars to its right have completed
Calculation: Confirmed swing low = the low at the center of a symmetric lookback window that equals the lowest low in that window; recognize it after the bars to its right have completed
Calculation: Wave C active = a confirmed swing high followed by a confirmed swing low followed by a confirmed swing high; remains active until the next confirmed swing low
Long: Buys are enabled after close < long-term moving average and remain enabled until an exit; wave C active AND close < long-term moving average AND open > close AND candle wick size > candle body size AND volume > volume average multiplied by a threshold AND first staged entry has not triggered
Long: Buys are enabled AND first staged entry has triggered AND close > short-term moving average AND prior close <= prior short-term moving average AND second staged entry has not triggered
Long: Buys are enabled AND second staged entry has triggered AND short-term moving average > long-term moving average AND prior short-term moving average <= prior long-term moving average AND final staged entry has not triggered
Exit: long, short-term moving average < long-term moving average AND prior short-term moving average >= prior long-term moving average AND final staged entry has triggered