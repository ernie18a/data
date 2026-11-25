Calculation: RangeHigh = Highest(high[1], lookback)
Calculation: RangeLow = Lowest(low[1], lookback)
Calculation: RangeSpan = max(RangeHigh - RangeLow, minimum span)
Calculation: ResistanceZone = RangeHigh - RangeSpan * zone percentage / 100
Calculation: SupportZone = RangeLow + RangeSpan * zone percentage / 100
Long: close[0] > RangeHigh
Long: close[0] >= RangeLow AND close[0] <= RangeHigh AND close[0] <= SupportZone AND close[0] < ResistanceZone
Short: close[0] < RangeLow
Short: close[0] >= RangeLow AND close[0] <= RangeHigh AND close[0] >= ResistanceZone