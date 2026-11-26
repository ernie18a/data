Calculation: InRange = datetime >= start datetime AND datetime <= stop datetime
Calculation: LongSignal = (close > open OR close > LOWEST(close, momentum lookback)[1]) AND close > EMA(close, trend lookback, T1, last completed bar) AND InRange
Calculation: ShortSignal = (close < open OR close < HIGHEST(close, momentum lookback)[1]) AND close < EMA(close, trend lookback, T1, last completed bar) AND InRange
Calculation: TrailStopLong = highest high since long entry * (1 - trailing stop percent / 100)
Calculation: TrailStopShort = lowest low since short entry * (1 + trailing stop percent / 100)
Long: LongSignal AND position side <> long
Long: LongSignal[1] AND high >= high[1] * (1 + long margin / 100)
Short: ShortSignal AND position side <> short
Short: ShortSignal[1] AND low <= low[1] * (1 - short margin / 100)
Exit: long, low <= TrailStopLong[1]
Exit: short, high >= TrailStopShort[1]
Exit: long, InRange[1] AND InRange = false
Exit: short, InRange[1] AND InRange = false