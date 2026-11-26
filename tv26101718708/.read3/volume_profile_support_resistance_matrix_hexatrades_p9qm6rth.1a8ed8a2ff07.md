Calculation: VolumeProfile = per-bin sum over the last profile lookback bars including the current bar of each bar's volume split evenly across the bins from its low to its high, with the bins dividing the lowest low to highest high of those bars into bin count equal heights
Calculation: Zones = midpoints of the kept candidates from up to candidate count iterations, each iteration taking the highest remaining VolumeProfile bin whose volume is at least minimum strength percent of the highest VolumeProfile bin, removing it and the bins within max(1, floor(gap / bin height)) bins of it, and keeping its midpoint if no kept midpoint is less than gap away and fewer than maximum zones per side are kept on its side (support if the midpoint is below close, otherwise resistance), where gap = max(minimum spacing bins * bin height, zone thickness multiplier * ATR(ATR lookback)) and bin height = (highest high - lowest low over the profile lookback bars) / bin count
Calculation: NearestResistance = lowest Zones price at or above close
Calculation: NearestSupport = highest Zones price below close
Long: close crosses above NearestResistance AND volume > SMA(volume, volume lookback)
Short: close crosses below NearestSupport AND volume > SMA(volume, volume lookback)
Long: low <= NearestSupport AND close > NearestSupport
Short: high >= NearestResistance AND close < NearestResistance
Long: close > VAH(VolumeProfile, value area percent)
Short: close < VAL(VolumeProfile, value area percent)