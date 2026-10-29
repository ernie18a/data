Calculation: Candle range = max(high − low, minimum tick)
Calculation: Body fraction = abs(close − open) / candle range
Calculation: Upper-wick fraction = (high − max(open, close)) / candle range
Calculation: Lower-wick fraction = (min(open, close) − low) / candle range
Long: close >= open OR (body fraction > 0.15 AND lower-wick fraction >= 0.40 AND lower-wick fraction > upper-wick fraction)
Short: close < open OR (body fraction > 0.15 AND upper-wick fraction >= 0.40 AND upper-wick fraction > lower-wick fraction)
