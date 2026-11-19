Calculation: VEL = JMA(if ATR normalization is enabled and ATR(ATR lookback) is nonzero, then change(source price, momentum lookback) * normalization scale / ATR(ATR lookback), else change(source price, momentum lookback), JMA lookback, phase, power); computed on chart bars or on higher-timeframe T1 bars and sampled onto chart bars from the current T1 bar (developing in real time, completed on historical bars).
Calculation: Histogram = VEL - JMA(VEL, signal JMA lookback, signal phase, signal power), when the histogram is enabled; computed on chart bars or on higher-timeframe T1 bars and sampled onto chart bars from the current T1 bar (developing in real time, completed on historical bars).
Long: VEL >= zero
Short: VEL < zero
Long: VEL crosses above zero on chart bars
Short: VEL crosses below zero on chart bars
Long: Histogram is enabled AND Histogram >= zero
Short: Histogram is enabled AND Histogram < zero
Long: Divergence detection is enabled AND a pivot low of VEL with the left pivot lookback and right pivot lookback is confirmed on a chart bar AND low[right pivot lookback] < low at the previous confirmed VEL pivot low AND the current pivot VEL value > the previous confirmed VEL pivot low value
Short: Divergence detection is enabled AND a pivot high of VEL with the left pivot lookback and right pivot lookback is confirmed on a chart bar AND high[right pivot lookback] > high at the previous confirmed VEL pivot high AND the current pivot VEL value < the previous confirmed VEL pivot high value