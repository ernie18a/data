Calculation: Z-score = (close − rolling mean(close)) / rolling standard deviation(close), using the same lookback for the mean and standard deviation
Calculation: Confirmed macro uptrend = the short-lookback SMA of close exceeds the longer-lookback SMA of close on at least N consecutive chart bars, using values from the still-forming higher-timeframe bar
Long: Confirmed macro uptrend AND Z-score < entry threshold
Exit: long, Z-score > exit threshold OR NOT Confirmed macro uptrend OR close < entry price × (1 − stop-loss percentage / 100)