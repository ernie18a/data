Calculation: ZLEMA(src, n) = EMA(2*src - src[lag], n), where lag = floor((n-1)/2)
Calculation: Wave = SMA(100 * (ZLEMA(close, n_wave) - lowest low over k bars) / max(highest high over k bars - lowest low over k bars, mintick), smoothing length); computed on chart-timeframe bars; k is a lookback longer than n_wave
Calculation: MoneyFlow = 100 * EMA(volume * (close - open) / max(high - low, mintick), m) / EMA(volume, m)
Calculation: RelVol = volume / SMA(volume, a)[1], where the average covers the a bars before the current bar and excludes it
Calculation: Wave pivot low (pivot high) = a bar whose Wave is the lowest (highest) among p bars on each side; it is confirmed p bars after the pivot bar, and the decision is evaluated on the confirmation bar
Long: Wave crosses up through the oversold level (previous Wave <= level AND current Wave > level) AND MoneyFlow > 0 AND close > open
Long: Wave crosses up through the midpoint level 50 (previous Wave <= 50 AND current Wave > 50) AND MoneyFlow > 0 AND RelVol >= volume multiplier (>= 1)
Long: a Wave pivot low is confirmed AND a previous Wave pivot low exists AND the bars between the two pivots <= max distance AND the low price at the new pivot < the low price at the previous pivot AND the Wave at the new pivot > the Wave at the previous pivot AND the Wave at the new pivot < 50
Short: Wave crosses down through the overbought level (previous Wave >= level AND current Wave < level) AND MoneyFlow <= 0 AND close < open
Short: Wave crosses down through the midpoint level 50 (previous Wave >= 50 AND current Wave < 50) AND MoneyFlow <= 0 AND RelVol >= volume multiplier (>= 1)
Short: a Wave pivot high is confirmed AND a previous Wave pivot high exists AND the bars between the two pivots <= max distance AND the high price at the new pivot > the high price at the previous pivot AND the Wave at the new pivot < the Wave at the previous pivot AND the Wave at the new pivot > 50