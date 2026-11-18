Calculation: LongSetup = volume > SMA(volume, volLength) AND close > open AND high - close < (close - open) * wickFraction AND high < SMA(close, maLength) AND low < SMA(close, maLength)
Calculation: ShortSetup = volume > SMA(volume, volLength) AND close < open AND close - low < (open - close) * wickFraction AND low > SMA(close, maLength) AND high > SMA(close, maLength)
Calculation: priorLongSetupLow = low of the most recent bar before the current bar on which LongSetup or ShortSetup is true, if LongSetup is true on that bar; otherwise NA
Long: LongSetup AND low > priorLongSetupLow