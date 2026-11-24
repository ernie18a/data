Calculation: NetVolume = buy-minus-sell volume delta of T1 bars forming the current bar when available, otherwise ((2 * close - high - low) / (high - low)) * volume, and 0 when high = low
Calculation: VolumeSpike = volume >= SMA(volume, sweep volume length) * sweep volume multiplier
Long: close > high[1] AND VolumeSpike[1] AND NetVolume[1] > 0 AND (for some k >= 2: level = PivotLow(low, pivot length, pivot length)[k] AND low[1] < level AND close[1] >= level AND level <= lowest(low, k + pivot length - 1)[2])
Long: EMA(NetVolume, pressure length) > 0
Long: NetVolume >= 0
Short: close < low[1] AND VolumeSpike[1] AND NetVolume[1] < 0 AND (for some k >= 2: level = PivotHigh(high, pivot length, pivot length)[k] AND high[1] > level AND close[1] <= level AND level >= highest(high, k + pivot length - 1)[2])
Short: EMA(NetVolume, pressure length) <= 0
Short: NetVolume < 0