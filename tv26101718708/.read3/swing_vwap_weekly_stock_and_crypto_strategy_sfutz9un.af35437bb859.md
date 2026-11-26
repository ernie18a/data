Long: close > VWAP(hlc3, volume, T1, bar still forming), sampled on chart bars
Short: close < VWAP(hlc3, volume, T1, bar still forming), sampled on chart bars
Exit: long, VWAP(hlc3, volume, T1, bar still forming)[1] > VWAP(hlc3, volume, T1, bar still forming), sampled on chart bars
Exit: short, VWAP(hlc3, volume, T1, bar still forming) > VWAP(hlc3, volume, T1, bar still forming)[1], sampled on chart bars