Calculation: composite = mean of SMA or EMA(close, shared lookback) on T1, T2, T3, T4, and T5, each evaluated on its timeframe’s current bar (including the bar still forming) and mapped to chart bars; for a timeframe below the chart timeframe, use its latest available intrabar; undefined unless all five values are available
Long: composite > composite[1]
Short: composite < composite[1]