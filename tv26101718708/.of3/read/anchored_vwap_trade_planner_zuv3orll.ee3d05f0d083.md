Calculation: DevZ = (close - AVWAP(hlc3, anchor)) / STDEV(close - AVWAP(hlc3, anchor), Z stdev lookback)
Calculation: Target(multiplier) = AVWAP at entry bar + (entry price - AVWAP at entry bar) * multiplier
Calculation: Stop = AVWAP at entry bar + (entry price - AVWAP at entry bar) * SL fraction - position side * SL buffer multiplier * ATR(stop lookback) at entry bar
Calculation: TrailLong = max(TrailLong[1], high - trail multiplier * ATR(trail lookback)) while highest high since entry >= Target(higher multiplier)
Calculation: TrailShort = min(TrailShort[1], low + trail multiplier * ATR(trail lookback)) while lowest low since entry <= Target(higher multiplier)
Long: close > AVWAP(hlc3, anchor) AND DevZ >= Z threshold AND bars since last Long or Short signal >= cooldown
Short: close < AVWAP(hlc3, anchor) AND DevZ <= -Z threshold AND bars since last Long or Short signal >= cooldown
Exit: Long, low <= Stop
Exit: Long, highest high since entry >= Target(lower multiplier) AND low <= entry price
Exit: Long, highest high since entry >= Target(higher multiplier) AND low <= Target(lower multiplier)
Exit: Long, high >= Target(lower multiplier)
Exit: Long, high >= Target(higher multiplier)
Exit: Long, TP3 option AND high >= Target(TP3 multiplier)
Exit: Long, trail option AND low <= TrailLong
Exit: Short, high >= Stop
Exit: Short, lowest low since entry <= Target(lower multiplier) AND high >= entry price
Exit: Short, lowest low since entry <= Target(higher multiplier) AND high >= Target(lower multiplier)
Exit: Short, low <= Target(lower multiplier)
Exit: Short, low <= Target(higher multiplier)
Exit: Short, TP3 option AND low <= Target(TP3 multiplier)
Exit: Short, trail option AND high >= TrailShort