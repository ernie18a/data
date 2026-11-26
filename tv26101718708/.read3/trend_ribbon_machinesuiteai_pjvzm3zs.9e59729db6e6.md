Calculation: Fastest core average = selected EMA, WMA, SMA, HMA, or VWMA of the selected price source over the fastest core lookback
Calculation: Second-fastest core average = selected EMA, WMA, SMA, HMA, or VWMA of the selected price source over the second-fastest core lookback
Calculation: Primary faster average = selected EMA, WMA, SMA, HMA, or VWMA of the selected price source over the primary faster lookback
Calculation: Primary slower average = selected EMA, WMA, SMA, HMA, or VWMA of the selected price source over the primary slower lookback
Calculation: Slowest core average = selected EMA, WMA, SMA, HMA, or VWMA of the selected price source over the slowest core lookback
Calculation: UpAlignment = count of adjacent core average pairs in which the faster average is above the slower average
Calculation: DownAlignment = count of adjacent core average pairs in which the faster average is below the slower average
Long: crosses above(Primary faster average, Primary slower average)
Short: crosses below(Primary faster average, Primary slower average)
Long: crosses above(Fastest core average, Second-fastest core average)
Short: crosses below(Fastest core average, Second-fastest core average)
Long: UpAlignment = 4 AND UpAlignment[1] < 4
Short: DownAlignment = 4 AND DownAlignment[1] < 4
Long: crosses above(Primary faster average, Primary slower average) AND volume is available AND SMA(volume, lookback) > 0 AND volume > SMA(volume, lookback) × multiplier
Short: crosses below(Primary faster average, Primary slower average) AND volume is available AND SMA(volume, lookback) > 0 AND volume > SMA(volume, lookback) × multiplier
Long: Primary faster average > Primary slower average AND UpAlignment >= 3
Short: Primary faster average <= Primary slower average AND DownAlignment >= 3