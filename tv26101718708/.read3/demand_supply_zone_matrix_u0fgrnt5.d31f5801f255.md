Calculation: Zone flow(side) = sum from the zone creation bar back to but excluding its anchor candle of +volume when close > open and -volume otherwise for demand, and -volume when close < open and +volume otherwise for supply
Calculation: Active zone volume(side) = sum of the absolute stored zone flows across active zones of that side
Calculation: Zone inside state = false when a zone is created; after each confirmed chart bar, true if high >= zone bottom AND low <= zone top, and false otherwise
Calculation: Zone cooldown(side) = cooldown length when a zone of that side is created, then decreases by one per confirmed chart bar
Long: On a confirmed chart bar, close > open for each of the last momentum length bars AND volume[1] > SMA(volume, volume-average lookback)[1] AND demand cooldown = 0 AND the nearest preceding bearish candle is within base lookback bars AND its interval [high(anchor) - ATR(ATR lookback) * zone-height multiplier, high(anchor)] overlaps no active demand zone
Short: On a confirmed chart bar, close < open for each of the last momentum length bars AND volume[1] > SMA(volume, volume-average lookback)[1] AND supply cooldown = 0 AND the nearest preceding bullish candle is within base lookback bars AND its interval [low(anchor), low(anchor) + ATR(ATR lookback) * zone-height multiplier] overlaps no active supply zone
Long: On a confirmed chart bar, high >= an active demand zone's bottom AND low <= its top AND its inside state is false AND more than momentum length bars have elapsed since its anchor candle
Short: On a confirmed chart bar, high >= an active supply zone's bottom AND low <= its top AND its inside state is false AND more than momentum length bars have elapsed since its anchor candle
Long: On a confirmed chart bar, close > the top of an active supply zone
Short: On a confirmed chart bar, close < the bottom of an active demand zone
Long: Active zone volume(demand) > active zone volume(supply) * bias ratio
Short: Active zone volume(supply) > active zone volume(demand) * bias ratio