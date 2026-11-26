Calculation: price-average score = count(close above the current moving average) - count(close below the current moving average) over the indicator lookback on T1 bars, including the forming bar
Long: price-average score > 0 AND hour(datetime) = entry hour AND minute(datetime) = entry minute
Short: price-average score < 0 AND hour(datetime) = entry hour AND minute(datetime) = entry minute
Exit: long, (hour(datetime) = exit hour AND minute(datetime) >= exit minute) OR hour(datetime) > exit hour OR hour(datetime) < entry hour
Exit: short, (hour(datetime) = exit hour AND minute(datetime) >= exit minute) OR hour(datetime) > exit hour OR hour(datetime) < entry hour