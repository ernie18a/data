Calculation: Long score = arithmetic mean of RSI(close, lookback) and MFI(close, lookback)
Calculation: Short score = arithmetic mean of RSI(1/close, lookback) and MFI(1/close, lookback)
Calculation: Long best hour = circular mean of each bar’s hour of day, weighted by its long score and cumulatively calculated over all bars
Calculation: Short best hour = circular mean of each bar’s hour of day, weighted by its short score and cumulatively calculated over all bars
Long: round(long best hour) = current hour of day
Short: round(short best hour) = current hour of day