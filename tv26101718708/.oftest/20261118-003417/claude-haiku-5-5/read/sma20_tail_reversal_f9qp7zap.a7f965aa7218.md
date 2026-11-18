Calculation: BaseLong = close > open AND high - close < wick ratio * (close - open) AND volume > SMA(volume, volume SMA length) AND high < SMA(close, price SMA length) AND low < SMA(close, price SMA length)
Calculation: BaseShort = close < open AND close - low < wick ratio * (open - close) AND volume > SMA(volume, volume SMA length) AND low > SMA(close, price SMA length) AND high > SMA(close, price SMA length)
Calculation: PrevBaseIsLong = the most recent bar before the current bar where BaseLong or BaseShort is true is a bar where BaseLong is true
Calculation: PrevBaseLongLow = low of the most recent bar before the current bar where BaseLong is true
Long: BaseLong AND PrevBaseIsLong AND low > PrevBaseLongLow