Calculation: low-volume threshold = SMA(volume, long lookback) - multiplier × standard deviation(volume, long lookback)
Long: unfiltered trend-turn entry mode AND SMA(close, half the long lookback) > SMA(close, half the long lookback)[1] AND SMA(close, half the long lookback)[1] <= SMA(close, half the long lookback)[2]
Short: unfiltered trend-turn entry mode AND SMA(close, half the long lookback) < SMA(close, half the long lookback)[1] AND SMA(close, half the long lookback)[1] >= SMA(close, half the long lookback)[2]
Long: low-volume-filtered entry mode AND SMA(close, half the long lookback) > SMA(close, half the long lookback)[1] AND SMA(volume, short lookback) > low-volume threshold
Short: low-volume-filtered entry mode AND SMA(close, half the long lookback) < SMA(close, half the long lookback)[1] AND SMA(volume, short lookback) > low-volume threshold
Exit: Long, SMA(close, half the long lookback) < SMA(close, half the long lookback)[1] OR (low-volume exits enabled AND SMA(volume, short lookback) <= low-volume threshold)
Exit: Short, SMA(close, half the long lookback) > SMA(close, half the long lookback)[1]