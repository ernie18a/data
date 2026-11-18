Calculation: PriceSMA = SMA(close, lookback)
Calculation: VolumeSMA = SMA(volume, separate lookback)
Calculation: BaseLong = volume > VolumeSMA AND close > open AND high - max(close, open) < abs(close - open) * wick ratio AND high < PriceSMA AND low < PriceSMA
Calculation: BaseShort = volume > VolumeSMA AND close < open AND min(close, open) - low < abs(close - open) * wick ratio AND low > PriceSMA AND high > PriceSMA
Long: BaseLong AND the previous base signal was BaseLong AND low > the low of that previous BaseLong