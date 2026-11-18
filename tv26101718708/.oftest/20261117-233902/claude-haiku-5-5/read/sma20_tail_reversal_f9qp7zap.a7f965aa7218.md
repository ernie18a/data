Calculation: LongSetup = volume > SMA(volume, volumeLookback) AND close > open AND high - close < wickRatio * (close - open) AND high < SMA(close, priceLookback)
Calculation: ShortSetup = volume > SMA(volume, volumeLookback) AND close < open AND close - low < wickRatio * (open - close) AND low > SMA(close, priceLookback)
Calculation: PriorLowIfUnbroken = low of the most recent bar before the current bar on which LongSetup is true, if no bar after that bar and before the current bar has ShortSetup true; otherwise NA
Long: LongSetup AND low > PriorLowIfUnbroken