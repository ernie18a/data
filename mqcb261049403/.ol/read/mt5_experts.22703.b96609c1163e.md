Calculation: Bar 0 = still-forming bar; bar 1 = last completed bar; bar 2 = preceding completed bar. Each indicator uses its configured timeframe, which may be higher than, lower than, or equal to the chart timeframe.
Calculation: Fast moving average uses a shorter lookback than the slow moving average.
Long: Slow moving average on bar 1 > slow moving average on bar 2 AND fast moving average on bar 0 > fast moving average on bar 1 AND truncated-toward-zero integer value of CCI on bar 0 < CCI lower threshold
Short: Slow moving average on bar 1 < slow moving average on bar 2 AND fast moving average on bar 0 < fast moving average on bar 1 AND truncated-toward-zero integer value of CCI on bar 0 > CCI upper threshold
Exit: Long, slow moving average on bar 1 <= slow moving average on bar 2
Exit: Short, slow moving average on bar 1 >= slow moving average on bar 2