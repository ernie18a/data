Calculation: anchored VWAP = VWAP(hlc3, anchor period)
Calculation: VWAP deviation distance = VWAP standard deviation(hlc3, anchor period)
Calculation: inner bands = anchored VWAP ± VWAP deviation distance × standard deviation multiplier
Calculation: outer bands = anchored VWAP ± VWAP deviation distance × standard deviation multiplier × outer-band multiplier
Long: crossover(close, upper inner band) AND (trend filter disabled OR anchored VWAP > anchored VWAP[1])
Short: crossunder(close, lower inner band) AND (trend filter disabled OR anchored VWAP <= anchored VWAP[1])
Long: hl2 > upper inner band
Short: hl2 < lower inner band
Long: anchored VWAP > anchored VWAP[1]
Short: anchored VWAP <= anchored VWAP[1]
Long: bars since crossover(close, upper inner band) < bars since crossunder(close, lower inner band)
Short: NOT (bars since crossover(close, upper inner band) < bars since crossunder(close, lower inner band))
Exit: long, crossunder(close, upper outer band)
Exit: short, crossover(close, lower outer band)