Calculation: SwingHigh = most recent PivotHigh(high, swing length, swing length)
Calculation: SwingLow = most recent PivotLow(low, swing length, swing length)
Calculation: SwingTrend = 1 if close > SwingHigh, -1 if close < SwingLow, otherwise SwingTrend[1]
Calculation: UpperTFSwingHigh = most recent PivotHigh(high, swing length, swing length) computed on T1 bars, taken by chart bars at the last completed T1 bar
Calculation: UpperTFSwingLow = most recent PivotLow(low, swing length, swing length) computed on T1 bars, taken by chart bars at the last completed T1 bar
Calculation: UpperTFTrend = 1 if last completed T1 close > UpperTFSwingHigh, -1 if last completed T1 close < UpperTFSwingLow, otherwise UpperTFTrend[1]
Calculation: InstrumentUp = EMA(close, instrument shorter lookback) >= EMA(close, instrument longer lookback)
Calculation: IndexUp = EMA(non-top-10 crypto dominance close, index shorter lookback) >= EMA(non-top-10 crypto dominance close, index longer lookback)
Calculation: BullishEma = EMA(close, instrument shorter lookback) > EMA(close, instrument longer lookback) OR (InstrumentUp AND NOT IndexUp)
Calculation: BearishEma = EMA(close, instrument shorter lookback) < EMA(close, instrument longer lookback)
Calculation: TrendColor = lime if InstrumentUp AND IndexUp; teal if InstrumentUp AND NOT IndexUp; maroon if NOT InstrumentUp AND EMA(non-top-10 crypto dominance close, index shorter lookback) > EMA(non-top-10 crypto dominance close, index longer lookback); otherwise red
Calculation: ReturnPct = 100 * (close - entry price) / entry price for long; 100 * (entry price - close) / entry price for short
Calculation: LongLockout = true from a bar where the position is long, ReturnPct < stop-loss threshold, and NOT BearishEma, until a bar where TrendColor[1] is lime or teal and TrendColor != maroon, or a bar where a short entry occurs
Calculation: ShortLockout = true from a bar where the position is short, ReturnPct < stop-loss threshold, and NOT BullishEma, until a bar where TrendColor[1] is red or maroon and TrendColor != teal, or a bar where a long entry occurs
Long: BullishEma AND SwingTrend = 1 AND RSI(close, RSI lookback) < overbought level AND NOT LongLockout AND position side != long
Short: BearishEma AND SwingTrend = -1 AND RSI(close, RSI lookback) > oversold level AND NOT ShortLockout AND position side != short
Long: SwingTrend = 1
Long: UpperTFTrend = 1
Long: TrendColor = lime OR TrendColor = teal
Short: SwingTrend = -1
Short: UpperTFTrend = -1
Short: TrendColor = maroon OR TrendColor = red
Exit: long, ReturnPct < stop-loss threshold
Exit: short, ReturnPct < stop-loss threshold
Exit: long, BearishEma
Exit: short, BullishEma
Exit: long, SwingTrend = -1
Exit: short, SwingTrend = 1
Exit: long, TrendColor[1] = lime AND TrendColor != lime AND NOT BearishEma AND ReturnPct > scale-out profit threshold AND no scale-out since entry
Exit: short, TrendColor[1] = red AND TrendColor != red AND NOT BullishEma AND ReturnPct > scale-out profit threshold AND no scale-out since entry
Exit: long, high > entry price + ATR(ATR lookback) at entry bar * TP factor * level-1 multiplier AND level-1 not yet hit since entry
Exit: long, high > entry price + ATR(ATR lookback) at entry bar * TP factor * level-2 multiplier AND level-2 not yet hit since entry
Exit: long, high > entry price + ATR(ATR lookback) at entry bar * TP factor * level-3 multiplier AND level-3 not yet hit since entry
Exit: short, low < entry price - ATR(ATR lookback) at entry bar * TP factor * level-1 multiplier AND level-1 not yet hit since entry
Exit: short, low < entry price - ATR(ATR lookback) at entry bar * TP factor * level-2 multiplier AND level-2 not yet hit since entry
Exit: short, low < entry price - ATR(ATR lookback) at entry bar * TP factor * level-3 multiplier AND level-3 not yet hit since entry