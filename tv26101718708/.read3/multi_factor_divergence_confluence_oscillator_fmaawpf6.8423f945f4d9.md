Calculation: Ratio(a, b) = a / b, or 0 if b = 0
Calculation: Z(x, L) = Ratio(x - SMA(x, L), STDEV(x, L))
Calculation: L1 = Z(close - VWAP(hlc3), normalization lookback)
Calculation: L2 = Z(high - low, normalization lookback) * (1 if close >= close[range lookback], else -1)
Calculation: L3 = Z(Ratio(close - close[efficiency lookback], SUM(|close - close[1]|, efficiency lookback)), normalization lookback)
Calculation: L4 = Z(close - reference spot close, normalization lookback)
Calculation: L5 = Z(MIN(Ratio(E, ATR(ATR lookback)), trend cap), normalization lookback) * D, where P = PSAR(start, increment, maximum), D = 1 if close > P, -1 if close < P, else 0, and E = high - P if D = 1, P - low if D = -1, else 0
Calculation: L6 = Z(RSI(close, RSI lookback), normalization lookback)
Calculation: L7 = Z(Ratio(close - LinReg(close, equilibrium lookback), ATR(ATR lookback)), normalization lookback)
Calculation: L8 = Z(KST(close, KST parameters), normalization lookback)
Calculation: L9 = Z(C - EMA(C, normalization lookback), normalization lookback), where C = cumulative sum of volume * Ratio((close - low) - (high - close), high - low)
Calculation: Included = the lenses i from 1 to 9 that are enabled and have Li defined, where lenses 1 and 9 also require cumulative volume > 0 and lens 4 also requires a nonzero reference spot close
Calculation: Comp = Ratio(sum of Li over i in Included, |Included|)
Calculation: CompSd = STDEV(Comp, composite lookback)
Calculation: CompOB = composite overbought multiple * CompSd if scaling enabled and CompSd > 0, else overbought threshold
Calculation: CompExt = composite extreme multiple * CompSd if scaling enabled and CompSd > 0, else extreme threshold
Calculation: GapMin = min gap multiple * STDEV(Comp, gap lookback)
Calculation: HP = PivotHigh(high, divergence pivot length, divergence pivot length)
Calculation: HD = HIGHEST(Comp, 2 * divergence pivot length + 1) if swing anchor enabled, else Comp[divergence pivot length]
Calculation: HB = bar index - divergence pivot length
Calculation: LP = PivotLow(low, divergence pivot length, divergence pivot length)
Calculation: LD = LOWEST(Comp, 2 * divergence pivot length + 1) if swing anchor enabled, else Comp[divergence pivot length]
Calculation: LB = bar index - divergence pivot length
Calculation: prev(X) = value of X at the previous bar where HP (for X = HP, HD, HB) or LP (for X = LP, LD, LB) is defined
Long: count of i in Included with Li <= -extreme threshold >= min(required lens count, |Included|) AND |Included| > 0
Long: Comp <= -CompOB
Long: divergence enabled AND LP defined AND LB - prev(LB) <= max bars between pivots AND LP < prev(LP) AND LD > prev(LD) AND LD - prev(LD) >= GapMin AND (extreme at pivot not required OR LD <= -CompOB)
Long: hidden enabled AND divergence enabled AND LP defined AND LB - prev(LB) <= max bars between pivots AND LP > prev(LP) AND LD < prev(LD) AND prev(LD) - LD >= GapMin
Long: reversal enabled AND PivotLow(Comp, reversal pivot length, reversal pivot length) <= -CompExt
Long: (1 in Included AND L1 >= 0) OR (2 in Included AND L2 >= 0) OR (3 in Included AND L3 >= 0) OR (4 in Included AND L4 >= 0) OR (5 in Included AND L5 >= 0) OR (6 in Included AND L6 >= 0) OR (7 in Included AND L7 >= 0) OR (8 in Included AND L8 >= 0) OR (9 in Included AND L9 >= 0)
Short: count of i in Included with Li >= extreme threshold >= min(required lens count, |Included|) AND |Included| > 0
Short: Comp >= CompOB
Short: divergence enabled AND HP defined AND HB - prev(HB) <= max bars between pivots AND HP > prev(HP) AND HD < prev(HD) AND prev(HD) - HD >= GapMin AND (extreme at pivot not required OR HD >= CompOB)
Short: hidden enabled AND divergence enabled AND HP defined AND HB - prev(HB) <= max bars between pivots AND HP < prev(HP) AND HD > prev(HD) AND HD - prev(HD) >= GapMin
Short: reversal enabled AND PivotHigh(Comp, reversal pivot length, reversal pivot length) >= CompExt
Short: (1 in Included AND L1 < 0) OR (2 in Included AND L2 < 0) OR (3 in Included AND L3 < 0) OR (4 in Included AND L4 < 0) OR (5 in Included AND L5 < 0) OR (6 in Included AND L6 < 0) OR (7 in Included AND L7 < 0) OR (8 in Included AND L8 < 0) OR (9 in Included AND L9 < 0)