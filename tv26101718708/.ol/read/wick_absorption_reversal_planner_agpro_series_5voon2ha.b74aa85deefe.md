Calculation: Lower wick = min(open, close) - low
Calculation: Upper wick = high - max(open, close)
Calculation: Candle range = high - low
Calculation: Relative volume = volume / average volume over a shorter lookback
Calculation: Prior context low = lowest low over a lookback, excluding the current bar
Calculation: Prior context high = highest high over a lookback, excluding the current bar
Calculation: Bullish absorption pocket = lower wick / ATR >= minimum wick size, lower wick / candle range >= minimum wick fraction, low <= prior context low, close > min(open, close), and relative volume >= minimum
Calculation: Bearish absorption pocket = upper wick / ATR >= minimum wick size, upper wick / candle range >= minimum wick fraction, high >= prior context high, close < max(open, close), and relative volume >= minimum
Calculation: Bullish reclaim rail = absorption candle's max(open, close) + ATR × reclaim buffer
Calculation: Bearish reclaim rail = absorption candle's min(open, close) - ATR × reclaim buffer
Calculation: Bullish failure shelf = absorption candle's low - ATR × failure buffer
Calculation: Bearish failure shelf = absorption candle's high + ATR × failure buffer
Long: bullish absorption pocket OR an active bullish pocket's later-bar close > bullish reclaim rail
Short: bearish absorption pocket OR an active bearish pocket's later-bar close < bearish reclaim rail
Exit: long, active bullish pocket's close < bullish failure shelf
Exit: short, active bearish pocket's close > bearish failure shelf