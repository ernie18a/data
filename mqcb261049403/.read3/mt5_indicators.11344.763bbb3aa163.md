Calculation: Fast = moving average(applied price, first smoothing method, first lookback, first phase)
Calculation: Slow = moving average(Fast, second smoothing method, second lookback, second phase)
Long: Fast > Slow
Short: Fast < Slow
Calculation: Fast T1 = moving average(applied price, first smoothing method, first lookback, first phase, T1 current bar still forming, calculated on T1 bars and carried onto chart bars)
Calculation: Slow T1 = moving average(Fast T1, second smoothing method, second lookback, second phase, T1 current bar still forming, calculated on T1 bars and carried onto chart bars)
Long: Fast T1 > Slow T1
Short: Fast T1 < Slow T1