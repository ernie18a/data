Calculation: RSI candle close = smooth((RSI of close − 50) × volume); use the selected smoothing method and its parameters throughout.
Calculation: RSI candle open = smooth((RSI of open − 50) × volume), replaced by the previous bar's RSI candle close when abs(open − close) ≤ the gap threshold.
Calculation: Upper and lower levels = the respective level parameter × smoothed volume.
Long: RSI candle close ≥ RSI candle open.
Short: RSI candle close < RSI candle open.
Long: Previous RSI candle close < 0 AND current RSI candle close ≥ 0.
Short: Previous RSI candle close > 0 AND current RSI candle close ≤ 0.
Long: Previous RSI candle close ≤ previous upper level AND current RSI candle close > current upper level.
Long: Previous RSI candle close ≤ previous lower level AND current RSI candle close > current lower level.
Short: Previous RSI candle close ≥ previous lower level AND current RSI candle close < current lower level.
Short: Previous RSI candle close > previous upper level AND current RSI candle close ≤ current upper level.