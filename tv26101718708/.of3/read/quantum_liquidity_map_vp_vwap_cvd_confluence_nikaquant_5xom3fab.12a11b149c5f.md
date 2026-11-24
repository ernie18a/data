Calculation: CVD = cumulative sum since the current T1 session start of volume * ((close - low) - (high - close)) / (high - low), with the term 0 when high = low
Calculation: ATR = ATR(ATR length)
Calculation: RVOL = volume / SMA(volume, volume average length)
Calculation: SwingHigh = PivotHigh(high, pivot length, pivot length)
Calculation: SwingLow = PivotLow(low, pivot length, pivot length)
Calculation: PriorSwingHigh = most recent non-NA SwingHigh before the current bar
Calculation: PriorSwingHighCVD = CVD at the bar where the PriorSwingHigh pivot occurred
Calculation: PriorSwingLow = most recent non-NA SwingLow before the current bar
Calculation: PriorSwingLowCVD = CVD at the bar where the PriorSwingLow pivot occurred
Calculation: PriorRangeHigh = Highest(high[1], sweep length)
Calculation: PriorRangeLow = Lowest(low[1], sweep length)
Calculation: IBHigh = highest high of bars in the current T1 session with datetime no later than session start plus IB duration
Calculation: IBLow = lowest low of bars in the current T1 session with datetime no later than session start plus IB duration
Calculation: Confluence = (close > VWAP(anchored at T2) ? component weight : -component weight) + (close > VAH(profile lookback, profile rows, value area percent) ? component weight : close < VAL(profile lookback, profile rows, value area percent) ? -component weight : 0) + MIN(component weight, MAX(-component weight, CVD / (cumulative volume since the current T1 session start) * 100 * delta scale)) + (CVD > EMA(CVD, CVD EMA length) ? component weight : -component weight) + (RVOL > upper RVOL threshold ? component weight : RVOL < lower RVOL threshold ? -component weight : 0)
Long: SwingLow < PriorSwingLow AND CVD[pivot length] > PriorSwingLowCVD AND PriorSwingLow - SwingLow > ATR * swing size ATR multiple
Short: SwingHigh > PriorSwingHigh AND CVD[pivot length] < PriorSwingHighCVD AND SwingHigh - PriorSwingHigh > ATR * swing size ATR multiple
Long: low < PriorRangeLow AND close > PriorRangeLow AND RVOL >= sweep RVOL threshold AND close > open
Short: high > PriorRangeHigh AND close < PriorRangeHigh AND RVOL >= sweep RVOL threshold AND close < open
Long: RVOL >= spike RVOL threshold AND close > open
Short: RVOL >= spike RVOL threshold AND close < open
Long: close > IBHigh AND no earlier bar in the current T1 session has close > IBHigh
Short: close < IBLow AND no earlier bar in the current T1 session has close < IBLow
Long: Confluence >= confluence threshold
Short: Confluence <= -confluence threshold