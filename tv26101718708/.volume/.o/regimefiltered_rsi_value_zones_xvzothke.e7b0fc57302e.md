Calculation: RSI = RSI of high over a lookback
Calculation: RSI moving average = selectable moving average of RSI, with a shorter lookback than the price regime moving average
Calculation: Price regime moving average = selectable moving average of close over a longer lookback than the RSI moving average
Calculation: Smoothed price Z-score = EMA of the close Z-score; close Z-score is (close − its lookback SMA) / its lookback standard deviation, or 0 when the standard deviation is 0
Long: RSI > RSI moving average OR close > price regime moving average OR smoothed price Z-score > threshold OR RSI <= buy-zone level AND previous bar RSI > buy-zone level
Short: RSI < RSI moving average OR close < price regime moving average OR smoothed price Z-score <= threshold
Exit: long, RSI >= sell-zone level AND previous bar RSI < sell-zone level