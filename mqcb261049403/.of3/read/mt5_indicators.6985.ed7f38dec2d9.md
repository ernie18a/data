Calculation: ChartBodyMean = SMA(close - open, chart lookback)
Calculation: T1BodyMean = SMA(close - open, T1 lookback, T1, still-forming bar), calculated on T1 bars and sampled by chart bars
Long: (ChartBodyMean > 0 AND ChartBodyMean <> ChartBodyMean[1]) OR (T1BodyMean > 0 AND T1BodyMean <> T1BodyMean[1 on T1])
Short: ChartBodyMean <= 0 OR (ChartBodyMean > 0 AND ChartBodyMean = ChartBodyMean[1]) OR T1BodyMean <= 0 OR (T1BodyMean > 0 AND T1BodyMean = T1BodyMean[1 on T1])