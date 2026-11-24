Calculation: KeltnerUpper = HMA(close, basis length) + ATR multiplier * ATR(ATR length)
Calculation: KeltnerLower = HMA(close, basis length) - ATR multiplier * ATR(ATR length)
Calculation: VolumeZScore = (volume - SMA(volume, volume lookback)) / STDEV(volume, volume lookback)
Calculation: UpBreak = close crosses above KeltnerUpper AND VolumeZScore >= volume Z threshold
Calculation: DownBreak = close crosses below KeltnerLower AND VolumeZScore >= volume Z threshold
Calculation: WithinBands = close < KeltnerUpper AND close > KeltnerLower
Long: UpBreak
Long: BarsSince(UpBreak) < BarsSince(DownBreak) AND BarsSince(WithinBands) >= BarsSince(UpBreak) - hold bars
Short: DownBreak
Short: BarsSince(DownBreak) < BarsSince(UpBreak) AND BarsSince(WithinBands) >= BarsSince(DownBreak) - hold bars
Exit: long, WithinBands
Exit: short, WithinBands