Calculation: WT1 = EMA of ((HLC3 − EMA(HLC3, channel length)) / (0.015 × EMA(abs(HLC3 − EMA(HLC3, channel length)), channel length)), using the WaveTrend average length
Calculation: WT2 = SMA(WT1, WaveTrend smoothing length)
Calculation: RSI+MFI = SMA(((close − open) / (high − low)) × multiplier, RSI+MFI period)
Long: EMA with the shorter lookback crosses above EMA with the longer lookback
Long: EMA with the shorter lookback crosses above EMA with the intermediate lookback
Long: open > EMA with the shorter lookback AND open > EMA with the longer lookback AND previous close > previous open AND close > open AND WT1 does not cross below WT2 AND the shorter EMA does not cross below the intermediate EMA
Long: WT1 crosses below WT2 AND WT2 is between its lower and upper bounds AND RSI is between its lower and upper bounds AND RSI+MFI is below its threshold
Short: EMA with the shorter lookback crosses below EMA with the intermediate lookback
Short: WT1 crosses below WT2