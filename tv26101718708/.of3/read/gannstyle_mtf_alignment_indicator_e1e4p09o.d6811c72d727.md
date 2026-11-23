Calculation: StructureDirection(bars, pivot lookback, break delay) = -1 if close < last confirmed PivotLow(bars, pivot lookback, pivot lookback) AND bars since that PivotLow was confirmed >= break delay; else 1 if close > last confirmed PivotHigh(bars, pivot lookback, pivot lookback) AND bars since that PivotHigh was confirmed >= break delay; else StructureDirection(bars, pivot lookback, break delay)[1]
Calculation: LongAligned = StructureDirection(chart bars, pivot lookback, break delay) = 1 AND StructureDirection(T1 bars, pivot lookback, break delay)[1] = 1 AND StructureDirection(T2 bars, pivot lookback, break delay)[1] = 1, with the T1 and T2 terms read at the last completed bar of their timeframe
Calculation: ShortAligned = StructureDirection(chart bars, pivot lookback, break delay) = -1 AND StructureDirection(T1 bars, pivot lookback, break delay)[1] = -1 AND StructureDirection(T2 bars, pivot lookback, break delay)[1] = -1, with the T1 and T2 terms read at the last completed bar of their timeframe
Calculation: LongStrong = LongAligned AND close > last confirmed PivotHigh(T1 bars, pivot lookback, pivot lookback) + strong margin * ATR(T1 bars, ATR length)[1] AND close > last confirmed PivotHigh(T2 bars, pivot lookback, pivot lookback) + strong margin * ATR(T2 bars, ATR length)[1], with the T1 and T2 terms read at the last completed bar of their timeframe
Calculation: ShortStrong = ShortAligned AND close < last confirmed PivotLow(T1 bars, pivot lookback, pivot lookback) - strong margin * ATR(T1 bars, ATR length)[1] AND close < last confirmed PivotLow(T2 bars, pivot lookback, pivot lookback) - strong margin * ATR(T2 bars, ATR length)[1], with the T1 and T2 terms read at the last completed bar of their timeframe
Calculation: EntrySignal = (LongAligned AND NOT LongAligned[1] OR ShortAligned AND NOT ShortAligned[1]) AND bar datetime within session window AND bars since EntrySignal was last true >= cooldown bars
Calculation: LongTP1 = highest high since entry (inclusive) >= entry price + ATR(ATR length) at entry bar * TP1 multiplier
Calculation: LongTrail = max(LongTrail[1], close - ATR(ATR length) * trail multiplier), starting at the first bar where LongTP1 is true
Calculation: ShortTP1 = lowest low since entry (inclusive) <= entry price - ATR(ATR length) at entry bar * TP1 multiplier
Calculation: ShortTrail = min(ShortTrail[1], close + ATR(ATR length) * trail multiplier), starting at the first bar where ShortTP1 is true
Long: LongAligned
Long: EntrySignal AND LongAligned
Long: EntrySignal AND LongStrong
Short: ShortAligned
Short: EntrySignal AND ShortAligned
Short: EntrySignal AND ShortStrong
Exit: long, NOT LongAligned
Exit: long, high >= entry price + ATR(ATR length) at entry bar * TP3 multiplier
Exit: long, low <= entry price - ATR(ATR length) at entry bar * stop multiplier
Exit: long, LongTP1 AND low <= max(entry price, LongTrail)
Exit: short, NOT ShortAligned
Exit: short, low <= entry price - ATR(ATR length) at entry bar * TP3 multiplier
Exit: short, high >= entry price + ATR(ATR length) at entry bar * stop multiplier
Exit: short, ShortTP1 AND high >= min(entry price, ShortTrail)