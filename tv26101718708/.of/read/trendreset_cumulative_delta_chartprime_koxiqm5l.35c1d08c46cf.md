Calculation: Trend state = start at 0; set to 1 when close > EMA + ATR, set to -1 when close < EMA - ATR, otherwise retain the prior state
Calculation: Cumulative delta = add volume when close > open, otherwise subtract volume; when trend state changes, start the cumulative delta with the current bar's signed volume
Calculation: Delta z-score = (cumulative delta - its moving average) / its standard deviation, using the same lookback for both
Calculation: Cumulative-delta pivot high/low = a local high/low in cumulative delta, confirmed using a longer lookback before the pivot than after it
Long: cumulative-delta pivot low is confirmed AND absolute delta z-score at the pivot bar >= its threshold AND current cumulative delta < 0
Short: cumulative-delta pivot high is confirmed AND absolute delta z-score at the pivot bar >= its threshold AND current cumulative delta > 0