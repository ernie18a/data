Calculation: RSI = Relative Strength Index of close
Calculation: EMA of RSI = Exponential moving average of RSI
Calculation: Average volume = Simple moving average of volume
Calculation: Intraday bar number = Count of bars since the date changed, starting at 1
Long: RSI crosses above EMA of RSI AND volume > Average volume AND intraday bar number != 6
Short: RSI < EMA of RSI AND intraday bar number != 6
Exit: long, (RSI < EMA of RSI AND intraday bar number != 6) OR intraday bar number = 6
Exit: short, (RSI crosses above EMA of RSI AND volume > Average volume AND intraday bar number != 6) OR intraday bar number = 6