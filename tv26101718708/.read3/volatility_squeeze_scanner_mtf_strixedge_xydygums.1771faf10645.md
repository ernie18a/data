Calculation: Squeeze(T) = (SMA(source, Bollinger lookback, T) - Bollinger multiplier × standard deviation(source, Bollinger lookback, T) > SMA(source, Keltner lookback, T) - Keltner multiplier × ATR(Keltner lookback, T)) AND (SMA(source, Bollinger lookback, T) + Bollinger multiplier × standard deviation(source, Bollinger lookback, T) < SMA(source, Keltner lookback, T) + Keltner multiplier × ATR(Keltner lookback, T)); calculate on T bars and use the latest available T value on chart bars (the still-forming T bar in real time, the last completed T bar historically)
Calculation: Momentum(T) = linear regression(source - average(average(highest(high, Keltner lookback, T), lowest(low, Keltner lookback, T)), SMA(source, Keltner lookback, T)), Keltner lookback); calculate on T bars and use the latest available T value on chart bars (the still-forming T bar in real time, the last completed T bar historically)
Long: Momentum(source, Keltner lookback, chart timeframe) >= 0
Short: Momentum(source, Keltner lookback, chart timeframe) < 0
Long: Momentum(T1) > 0
Short: Momentum(T1) <= 0
Long: Momentum(T2) > 0
Short: Momentum(T2) <= 0
Long: Momentum(T3) > 0
Short: Momentum(T3) <= 0
Long: Momentum(T4) > 0
Short: Momentum(T4) <= 0
Long: Momentum(T1) on the current chart bar > Momentum(T1) on the previous chart bar
Short: Momentum(T1) on the current chart bar <= Momentum(T1) on the previous chart bar
Long: Momentum(T2) on the current chart bar > Momentum(T2) on the previous chart bar
Short: Momentum(T2) on the current chart bar <= Momentum(T2) on the previous chart bar
Long: Momentum(T3) on the current chart bar > Momentum(T3) on the previous chart bar
Short: Momentum(T3) on the current chart bar <= Momentum(T3) on the previous chart bar
Long: Momentum(T4) on the current chart bar > Momentum(T4) on the previous chart bar
Short: Momentum(T4) on the current chart bar <= Momentum(T4) on the previous chart bar
Long: At least 3 of Momentum(T1), Momentum(T2), Momentum(T3), and Momentum(T4) are > 0
Short: At most 1 of Momentum(T1), Momentum(T2), Momentum(T3), and Momentum(T4) is > 0
Long: At least minimum timeframe consensus of Squeeze(T1), Squeeze(T2), Squeeze(T3), and Squeeze(T4) are true AND at least 3 of Momentum(T1), Momentum(T2), Momentum(T3), and Momentum(T4) are > 0
Short: At least minimum timeframe consensus of Squeeze(T1), Squeeze(T2), Squeeze(T3), and Squeeze(T4) are true AND at most 1 of Momentum(T1), Momentum(T2), Momentum(T3), and Momentum(T4) is > 0