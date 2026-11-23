Calculation: RangePosition = (close - low) / (high - low), or 0.5 when high = low
Calculation: AbsorbLong = PercentRank(volume, window) >= volume threshold AND volume > 0 AND RangePosition >= 1 - close threshold AND (trend length = 0 OR close > EMA(close, trend length))
Calculation: AbsorbShort = PercentRank(volume, window) >= volume threshold AND volume > 0 AND RangePosition <= close threshold AND (trend length = 0 OR close < EMA(close, trend length))
Calculation: Stage = if ABS(Stage[1]) in {1, 2, 3} AND Age[1] + 1 < setup TTL AND NOT ((Stage[1] > 0 AND close < Anchor[1]) OR (Stage[1] < 0 AND close > Anchor[1])), then Stage[1] moved one step away from 0 if its gate fills, else Stage[1]; otherwise +1 if AbsorbLong, -1 if AbsorbShort, else 0; where the gate for +1 is close > open, for +2 is PercentRank(ABS(close - open), window) >= body threshold AND close > open, for +3 is low <= Origin[1] AND close > Origin[1] AND no position open after this bar's exits, for -1 is close < open, for -2 is PercentRank(ABS(close - open), window) >= body threshold AND close < open, and for -3 is high >= Origin[1] AND close < Origin[1] AND no position open after this bar's exits
Calculation: Age = 0 if Stage != Stage[1], else Age[1] + 1
Calculation: Anchor = low if Stage = +1, high if Stage = -1, else Anchor[1]
Calculation: Origin = open if ABS(Stage) = 3 and ABS(Stage[1]) = 2, else Origin[1]
Calculation: Stop = for a long position, Anchor on the entry bar - stop buffer * tick size; for a short position, Anchor on the entry bar + stop buffer * tick size
Calculation: Target = for a long position, entry price + target multiple * ABS(entry price - Stop); for a short position, entry price - target multiple * ABS(entry price - Stop)
Long: Stage = +4
Short: Stage = -4
Exit: long, low <= Stop
Exit: long, high >= Target
Exit: short, high >= Stop
Exit: short, low <= Target