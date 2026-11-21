Calculation: Impulse = close[base bars] - close[base bars + impulse lookback]
Calculation: RangeHigh = Highest(high[1], base bars)
Calculation: RangeLow = Lowest(low[1], base bars)
Calculation: RangeTight = RangeHigh - RangeLow <= ATR(ATR length) * base ATR multiplier
Calculation: BreakUp = close > RangeHigh AND close[1] <= RangeHigh
Calculation: BreakDown = close < RangeLow AND close[1] >= RangeLow
Calculation: BuyBreak = BreakUp AND RangeTight AND ABS(Impulse) > ATR(ATR length) * impulse ATR multiplier
Calculation: SellBreak = BreakDown AND RangeTight AND ABS(Impulse) > ATR(ATR length) * impulse ATR multiplier
Calculation: DoubleBottomPair = a PivotLow(low, pivot length, pivot length) is confirmed on this bar AND ABS(that PivotLow - previous confirmed PivotLow) <= pivot tolerance * point AND the two pivot bars are at most pivot max bars apart
Calculation: DoubleBottomNeck = Highest(high, pivot max bars) at the latest bar where DoubleBottomPair is true
Calculation: DoubleBottomBreak = close > DoubleBottomNeck AND Highest(close[1], bars since latest DoubleBottomPair) <= DoubleBottomNeck
Calculation: DoubleTopPair = a PivotHigh(high, pivot length, pivot length) is confirmed on this bar AND ABS(that PivotHigh - previous confirmed PivotHigh) <= pivot tolerance * point AND the two pivot bars are at most pivot max bars apart
Calculation: DoubleTopNeck = Lowest(low, pivot max bars) at the latest bar where DoubleTopPair is true
Calculation: DoubleTopBreak = close < DoubleTopNeck AND Lowest(close[1], bars since latest DoubleTopPair) >= DoubleTopNeck
Calculation: AnyBreak = BuyBreak OR SellBreak OR DoubleBottomBreak OR DoubleTopBreak
Calculation: LongStopDistance = Round(Clamp((entry price - Lowest(low, swing length) at entry bar) / point + stop buffer points, min stop points, max stop points)) * point
Calculation: ShortStopDistance = Round(Clamp((Highest(high, swing length) at entry bar - entry price) / point + stop buffer points, min stop points, max stop points)) * point
Calculation: LongTp1 = entry price + LongStopDistance * TP1 RR
Calculation: LongTp2 = entry price + LongStopDistance * TP2 RR
Calculation: ShortTp1 = entry price - ShortStopDistance * TP1 RR
Calculation: ShortTp2 = entry price - ShortStopDistance * TP2 RR
Calculation: LongTp1Reached = Highest(high, bars after entry bar and before current bar) >= LongTp1
Calculation: ShortTp1Reached = Lowest(low, bars after entry bar and before current bar) <= ShortTp1
Long: Impulse > ATR(ATR length) * impulse ATR multiplier AND RangeTight AND BreakUp
Long: Impulse < -ATR(ATR length) * impulse ATR multiplier AND RangeTight AND BreakUp
Long: DoubleBottomBreak
Long: BuyBreak at bar b, where b is within the last retest window bars including the current bar, AND AnyBreak did not occur after bar b AND no SellBreak or DoubleTopBreak occurred at bar b AND no long entry occurred since bar b AND low <= RangeHigh at bar b AND close >= RangeHigh at bar b AND close > open
Long: Impulse > ATR(ATR length) * impulse ATR multiplier AND RangeTight AND BreakUp AND bar datetime within trading session AND position flat AND close(T1, last completed bar) > EMA(close, HTF EMA lookback, T1, last completed bar) AND (close > EMA(close, middle lookback) OR (EMA(close, shorter lookback) > EMA(close, middle lookback) AND EMA(close, middle lookback) > EMA(close, longer lookback)))
Long: Impulse < -ATR(ATR length) * impulse ATR multiplier AND RangeTight AND BreakUp AND bar datetime within trading session AND position flat AND close(T1, last completed bar) > EMA(close, HTF EMA lookback, T1, last completed bar) AND (close > EMA(close, middle lookback) OR (EMA(close, shorter lookback) > EMA(close, middle lookback) AND EMA(close, middle lookback) > EMA(close, longer lookback)))
Long: DoubleBottomBreak AND bar datetime within trading session AND position flat AND close(T1, last completed bar) > EMA(close, HTF EMA lookback, T1, last completed bar) AND (close > EMA(close, middle lookback) OR (EMA(close, shorter lookback) > EMA(close, middle lookback) AND EMA(close, middle lookback) > EMA(close, longer lookback)))
Long: BuyBreak at bar b, where b is within the last retest window bars including the current bar, AND AnyBreak did not occur after bar b AND no SellBreak or DoubleTopBreak occurred at bar b AND no long entry occurred since bar b AND low <= RangeHigh at bar b AND close >= RangeHigh at bar b AND close > open AND bar datetime within trading session AND position flat AND close(T1, last completed bar) > EMA(close, HTF EMA lookback, T1, last completed bar) AND (close > EMA(close, middle lookback) OR (EMA(close, shorter lookback) > EMA(close, middle lookback) AND EMA(close, middle lookback) > EMA(close, longer lookback)))
Short: Impulse < -ATR(ATR length) * impulse ATR multiplier AND RangeTight AND BreakDown
Short: Impulse > ATR(ATR length) * impulse ATR multiplier AND RangeTight AND BreakDown
Short: DoubleTopBreak
Short: SellBreak at bar b, where b is within the last retest window bars including the current bar, AND AnyBreak did not occur after bar b AND no BuyBreak or DoubleBottomBreak occurred at bar b AND no short entry occurred since bar b AND high >= RangeLow at bar b AND close <= RangeLow at bar b AND close < open
Short: Impulse < -ATR(ATR length) * impulse ATR multiplier AND RangeTight AND BreakDown AND bar datetime within trading session AND position flat AND close(T1, last completed bar) < EMA(close, HTF EMA lookback, T1, last completed bar) AND (close < EMA(close, middle lookback) OR (EMA(close, shorter lookback) < EMA(close, middle lookback) AND EMA(close, middle lookback) < EMA(close, longer lookback)))
Short: Impulse > ATR(ATR length) * impulse ATR multiplier AND RangeTight AND BreakDown AND bar datetime within trading session AND position flat AND close(T1, last completed bar) < EMA(close, HTF EMA lookback, T1, last completed bar) AND (close < EMA(close, middle lookback) OR (EMA(close, shorter lookback) < EMA(close, middle lookback) AND EMA(close, middle lookback) < EMA(close, longer lookback)))
Short: DoubleTopBreak AND bar datetime within trading session AND position flat AND close(T1, last completed bar) < EMA(close, HTF EMA lookback, T1, last completed bar) AND (close < EMA(close, middle lookback) OR (EMA(close, shorter lookback) < EMA(close, middle lookback) AND EMA(close, middle lookback) < EMA(close, longer lookback)))
Short: SellBreak at bar b, where b is within the last retest window bars including the current bar, AND AnyBreak did not occur after bar b AND no BuyBreak or DoubleBottomBreak occurred at bar b AND no short entry occurred since bar b AND high >= RangeLow at bar b AND close <= RangeLow at bar b AND close < open AND bar datetime within trading session AND position flat AND close(T1, last completed bar) < EMA(close, HTF EMA lookback, T1, last completed bar) AND (close < EMA(close, middle lookback) OR (EMA(close, shorter lookback) < EMA(close, middle lookback) AND EMA(close, middle lookback) < EMA(close, longer lookback)))
Exit: long, low <= entry price - LongStopDistance AND NOT LongTp1Reached
Exit: long, low <= entry price + BE offset points * point AND LongTp1Reached
Exit: long, high >= LongTp1 AND NOT LongTp1Reached
Exit: long, high >= LongTp2
Exit: short, high >= entry price + ShortStopDistance AND NOT ShortTp1Reached
Exit: short, high >= entry price - BE offset points * point AND ShortTp1Reached
Exit: short, low <= ShortTp1 AND NOT ShortTp1Reached
Exit: short, low <= ShortTp2