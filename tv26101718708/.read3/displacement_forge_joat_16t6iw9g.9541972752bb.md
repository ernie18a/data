Calculation: ZScore = (close - close[1] - SMA(close - close[1], Z-score length)) / STDEV(close - close[1], Z-score length)
Calculation: BullOriginBar = smallest k from 1 to Impulse lookback such that close[k] < open[k], or 1 if no such k
Calculation: BearOriginBar = smallest k from 1 to Impulse lookback such that close[k] > open[k], or 1 if no such k
Calculation: BullZoneTop = high[BullOriginBar]
Calculation: BullZoneBottom = low[BullOriginBar]
Calculation: BearZoneTop = high[BearOriginBar]
Calculation: BearZoneBottom = low[BearOriginBar]
Calculation: BullDisplacement = ZScore > Z-score threshold AND close > open AND close > Highest(close, Impulse lookback)[1] AND (NOT EMA filter enabled OR close > EMA(close, EMA length)) AND (NOT VWAP filter enabled OR close > VWAP(hlc3, anchored at each T1 start))
Calculation: BearDisplacement = ZScore < -Z-score threshold AND close < open AND close < Lowest(close, Impulse lookback)[1] AND (NOT EMA filter enabled OR close < EMA(close, EMA length)) AND (NOT VWAP filter enabled OR close < VWAP(hlc3, anchored at each T1 start))
Calculation: BullZoneCreated = BullDisplacement AND (NOT Overlap prevention enabled OR NOT (exists k from 1 to Zone max age * Zone expiry multiple + 1 such that ((BullZoneCreated[k] AND close[j] >= BullZoneBottom[k] for every j from 1 to k AND BullZoneTop[k] >= BullZoneBottom AND BullZoneBottom[k] <= BullZoneTop) OR (BearZoneCreated[k] AND close[j] <= BearZoneTop[k] for every j from 1 to k AND BearZoneTop[k] >= BullZoneBottom AND BearZoneBottom[k] <= BullZoneTop))))
Calculation: BearZoneCreated = BearDisplacement AND (NOT Overlap prevention enabled OR NOT (exists k from 1 to Zone max age * Zone expiry multiple + 1 such that ((BearZoneCreated[k] AND close[j] <= BearZoneTop[k] for every j from 1 to k AND BearZoneTop[k] >= BearZoneBottom AND BearZoneBottom[k] <= BearZoneTop) OR (BullZoneCreated[k] AND close[j] >= BullZoneBottom[k] for every j from 1 to k AND BullZoneTop[k] >= BearZoneBottom AND BullZoneBottom[k] <= BearZoneTop))))
Long: BullDisplacement
Short: BearDisplacement
Long: BullZoneCreated
Short: BearZoneCreated
Long: exists k from 0 to Zone max age * Zone expiry multiple such that BullZoneCreated[k] AND close[j] >= BullZoneBottom[k] for every j from 0 to k AND low <= BullZoneTop[k] AND low >= BullZoneBottom[k] AND open <= BullZoneTop[k] AND close > open AND close - low > Bounce fraction * (BullZoneTop[k] - BullZoneBottom[k])
Short: exists k from 0 to Zone max age * Zone expiry multiple such that BearZoneCreated[k] AND close[j] <= BearZoneTop[k] for every j from 0 to k AND high <= BearZoneTop[k] AND high >= BearZoneBottom[k] AND open >= BearZoneBottom[k] AND close < open AND high - close > Bounce fraction * (BearZoneTop[k] - BearZoneBottom[k])