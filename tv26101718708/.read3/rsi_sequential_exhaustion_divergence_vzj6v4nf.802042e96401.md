Calculation: RsiValue = RSI(close, RSI length)
Calculation: LogReturn = LN(close / close[1])
Calculation: VolShock = STDEV(LogReturn, volatility window) > 0 AND ABS(LogReturn) > shock threshold * STDEV(LogReturn, volatility window)
Calculation: ClusterIntensity = ClusterIntensity[1] * EXP(-decay) + IF(VolShock, excitation, 0)
Calculation: ShockRate = SMA(IF(VolShock, 1, 0), baseline window)
Calculation: VolLift = IF(vol-cluster filter enabled AND ShockRate > 0 AND ClusterIntensity > warning multiple * ShockRate, max lift * MIN(1, (ClusterIntensity / ShockRate - warning multiple) / lift span), 0)
Calculation: HtfUp = close(T1, last completed bar) > EMA(close, HTF EMA length, T1, last completed bar)
Calculation: MtfBulls = number of T in {T2, T3, T4} with close(T, last completed bar) > EMA(close, MTF EMA length, T, last completed bar)
Calculation: AdxBelowThreshold = ADX(high, low, close, ADX length, ADX smoothing) < ADX threshold
Calculation: SessionAllowed = NOT session skip enabled OR chart timeframe >= T5 OR no day change yet OR BarsSince(day of datetime changes) >= session skip bars
Calculation: RsiLowPivot = PIVOTLOW(RsiValue, pivot left, pivot right)
Calculation: RsiHighPivot = PIVOTHIGH(RsiValue, pivot left, pivot right)
Calculation: PrevRsiLow = VALUEWHEN(RsiLowPivot is not NA, RsiLowPivot, 1)
Calculation: PrevLowPrice = VALUEWHEN(RsiLowPivot is not NA, low[pivot right], 1)
Calculation: PrevRsiHigh = VALUEWHEN(RsiHighPivot is not NA, RsiHighPivot, 1)
Calculation: PrevHighPrice = VALUEWHEN(RsiHighPivot is not NA, high[pivot right], 1)
Calculation: LongDivergence = min bars between pivots <= BarsSince(RsiLowPivot is not NA)[1] + 1 <= max bars between pivots AND ((RsiLowPivot > PrevRsiLow + min RSI gap AND low[pivot right] < PrevLowPrice) OR (RsiLowPivot < PrevRsiLow - min RSI gap AND low[pivot right] > PrevLowPrice))
Calculation: ShortDivergence = min bars between pivots <= BarsSince(RsiHighPivot is not NA)[1] + 1 <= max bars between pivots AND ((RsiHighPivot < PrevRsiHigh - min RSI gap AND high[pivot right] > PrevHighPrice) OR (RsiHighPivot > PrevRsiHigh + min RSI gap AND high[pivot right] < PrevHighPrice))
Calculation: LongLabel = LongDivergence AND (no previous LongLabel OR BarsSince(LongLabel)[1] + 1 >= divergence cooldown)
Calculation: ShortLabel = ShortDivergence AND (no previous ShortLabel OR BarsSince(ShortLabel)[1] + 1 >= divergence cooldown)
Calculation: LongConfluence = number of true among: HtfUp; AdxBelowThreshold; BarsSince(LongLabel) + pivot right <= confluence window; volume > SMA(volume, volume SMA length)
Calculation: ShortConfluence = number of true among: NOT HtfUp; AdxBelowThreshold; BarsSince(ShortLabel) + pivot right <= confluence window; volume > SMA(volume, volume SMA length)
Long: RsiValue < RsiValue[1] AND RsiValue[1] < RsiValue[2] AND RsiValue[2] < RsiValue[3] AND RsiValue[3] < oversold level AND RsiValue[4] > oversold level AND (NOT HTF filter enabled OR HtfUp) AND (NOT regime filter enabled OR AdxBelowThreshold) AND SessionAllowed AND LongConfluence >= minimum confluence + ROUND(VolLift) AND (NOT MTF filter enabled OR MtfBulls >= MTF min agreement)
Short: RsiValue > RsiValue[1] AND RsiValue[1] > RsiValue[2] AND RsiValue[2] > RsiValue[3] AND RsiValue[3] > overbought level AND RsiValue[4] < overbought level AND (NOT HTF filter enabled OR NOT HtfUp) AND (NOT regime filter enabled OR AdxBelowThreshold) AND SessionAllowed AND ShortConfluence >= minimum confluence + ROUND(VolLift) AND (NOT MTF filter enabled OR 3 - MtfBulls >= MTF min agreement)
Long: LongDivergence
Long: LongLabel
Short: ShortDivergence
Short: ShortLabel
Long: RsiValue >= midline level
Short: RsiValue < midline level