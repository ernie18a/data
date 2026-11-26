Calculation: BullFVG(T) = low[0] > high[2] AND low[0] - high[2] >= minimum gap of T, evaluated on T bars where [0] is the last completed T bar and [n] is n T bars earlier; its zone has lower boundary high[2] and upper boundary low[0]
Calculation: BearFVG(T) = high[0] < low[2] AND low[2] - high[0] >= minimum gap of T, evaluated on T bars where [0] is the last completed T bar; its zone has lower boundary high[0] and upper boundary low[2]
Calculation: Kind(zone of T) = state of a zone formed by BullFVG(T) with origin bullish FVG or by BearFVG(T) with origin bearish FVG; Kind starts at its origin on the first chart bar after the zone's third candle closes; C = conversion count; in confirmed lifecycle mode, evaluated at each completed T bar: bearish FVG becomes bullish IFVG when the last C completed T closes are all above its upper boundary; bullish FVG becomes bearish IFVG when the last C completed T closes are all below its lower boundary; bullish IFVG becomes removed when the last N_bull(T) completed T closes are all below its lower boundary; bearish IFVG becomes removed when the last N_bear(T) completed T closes are all above its upper boundary; removal applies only if invalidation is enabled for T; in persistent lifecycle mode, evaluated on each chart bar: a zone with origin BearFVG becomes bullish IFVG when chart close is above its upper boundary and bearish FVG when chart close is below its lower boundary, and a zone with origin BullFVG becomes bullish FVG when chart close is above its upper boundary and bearish IFVG when chart close is below its lower boundary, otherwise Kind is unchanged; any zone becomes removed when older than lookback of T
Long: BullFVG(T1)
Short: BearFVG(T1)
Long: for a zone of T1, Kind[0] = bullish IFVG AND Kind[1] != bullish IFVG
Short: for a zone of T1, Kind[0] = bearish IFVG AND Kind[1] != bearish IFVG
Long: for a zone of T1 with Kind bullish FVG or bullish IFVG, chart low <= upper boundary for the first time since its current Kind began
Short: for a zone of T1 with Kind bearish FVG or bearish IFVG, chart high >= lower boundary for the first time since its current Kind began
Long: BullFVG(T2)
Short: BearFVG(T2)
Long: for a zone of T2, Kind[0] = bullish IFVG AND Kind[1] != bullish IFVG
Short: for a zone of T2, Kind[0] = bearish IFVG AND Kind[1] != bearish IFVG
Long: for a zone of T2 with Kind bullish FVG or bullish IFVG, chart low <= upper boundary for the first time since its current Kind began
Short: for a zone of T2 with Kind bearish FVG or bearish IFVG, chart high >= lower boundary for the first time since its current Kind began
Long: BullFVG(T3)
Short: BearFVG(T3)
Long: for a zone of T3, Kind[0] = bullish IFVG AND Kind[1] != bullish IFVG
Short: for a zone of T3, Kind[0] = bearish IFVG AND Kind[1] != bearish IFVG
Long: for a zone of T3 with Kind bullish FVG or bullish IFVG, chart low <= upper boundary for the first time since its current Kind began
Short: for a zone of T3 with Kind bearish FVG or bearish IFVG, chart high >= lower boundary for the first time since its current Kind began
Long: BullFVG(T4)
Short: BearFVG(T4)
Long: for a zone of T4, Kind[0] = bullish IFVG AND Kind[1] != bullish IFVG
Short: for a zone of T4, Kind[0] = bearish IFVG AND Kind[1] != bearish IFVG
Long: for a zone of T4 with Kind bullish FVG or bullish IFVG, chart low <= upper boundary for the first time since its current Kind began
Short: for a zone of T4 with Kind bearish FVG or bearish IFVG, chart high >= lower boundary for the first time since its current Kind began
Long: BullFVG(T5)
Short: BearFVG(T5)