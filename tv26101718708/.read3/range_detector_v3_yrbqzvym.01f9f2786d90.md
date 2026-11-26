Calculation: RelVol = volume / SMA(volume, relative volume lookback)
Calculation: RangeTop = highest high since the range start bar, excluding the current bar
Calculation: RangeBottom = lowest low since the range start bar, excluding the current bar
Calculation: RangeMid = (RangeTop + RangeBottom) / 2
Calculation: RangeConfirmed = the range detector is in its confirmed state
Calculation: BreakBars = bars since the most recent range break, up or down
Calculation: BreakDir = direction of the most recent range break, up or down
Calculation: BreakLevel = RangeTop at the bar of the most recent range break if that break was up, otherwise RangeBottom at that bar
Long: RangeConfirmed AND high > RangeTop AND close > RangeTop AND ABS(close - open) >= displacement factor * ATR(atr length) AND RelVol >= participation factor AND close > open
Short: RangeConfirmed AND low < RangeBottom AND close < RangeBottom AND ABS(close - open) >= displacement factor * ATR(atr length) AND RelVol >= participation factor AND close < open
Long: BreakDir = up AND BreakBars >= retest minimum delay AND BreakBars <= retest lookback AND low <= BreakLevel AND close > BreakLevel AND close > open
Short: BreakDir = down AND BreakBars >= retest minimum delay AND BreakBars <= retest lookback AND high >= BreakLevel AND close < BreakLevel AND close < open
Long: RangeConfirmed AND close < RangeMid
Short: RangeConfirmed AND close >= RangeMid