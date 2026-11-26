Calculation: Phase(size) = bearish if high[size] > Highest(high, size), else bullish if low[size] < Lowest(low, size), else previous Phase(size); initially bearish
Calculation: PivotHigh(size) = high[size] at the latest bar where Phase(size) changes from bullish to bearish
Calculation: PivotLow(size) = low[size] at the latest bar where Phase(size) changes from bearish to bullish
Calculation: SwingBullBreak(longer size) = close crosses above PivotHigh(longer size) AND close has not crossed above PivotHigh(longer size) since it was set
Calculation: SwingBearBreak(longer size) = close crosses below PivotLow(longer size) AND close has not crossed below PivotLow(longer size) since it was set
Calculation: InternalBullBreak(shorter size) = close crosses above PivotHigh(shorter size) AND PivotHigh(shorter size) != PivotHigh(longer size) AND close has not crossed above PivotHigh(shorter size) since it was set AND (not confluence filter OR high - max(close, open) > min(close, open - low))
Calculation: InternalBearBreak(shorter size) = close crosses below PivotLow(shorter size) AND PivotLow(shorter size) != PivotLow(longer size) AND close has not crossed below PivotLow(shorter size) since it was set AND (not confluence filter OR high - max(close, open) < min(close, open - low))
Calculation: ZoneHigh = low if high - low >= range multiple * ATR(atr length), else high
Calculation: ZoneLow = high if high - low >= range multiple * ATR(atr length), else low
Calculation: BullOB = for each bar where SwingBullBreak(longer size) or InternalBullBreak(shorter size) holds, a zone with bottom ZoneLow and top ZoneHigh of the bar with the lowest ZoneLow from the broken PivotHigh's bar through this bar; the zone is removed once low < bottom
Calculation: BearOB = for each bar where SwingBearBreak(longer size) or InternalBearBreak(shorter size) holds, a zone with bottom ZoneLow and top ZoneHigh of the bar with the highest ZoneHigh from the broken PivotLow's bar through this bar; the zone is removed once high > top
Calculation: PctChange(T1) = (close[1] - open[1]) / (open[1] * 100), where [1] is the last completed T1 bar
Calculation: GapThreshold = threshold multiple * (cumulative sum of abs(PctChange(T1)) taken on chart bars where a T1 bar starts) / chart bar count, or 0 if not auto threshold
Long: SwingBullBreak(longer size)
Long: InternalBullBreak(shorter size)
Short: SwingBearBreak(longer size)
Short: InternalBearBreak(shorter size)
Long: forming T1 low > T1 high[2] AND T1 close[1] > T1 high[2] AND PctChange(T1) > GapThreshold AND a T1 bar starts on this chart bar
Short: forming T1 high < T1 low[2] AND T1 close[1] < T1 low[2] AND -PctChange(T1) > GapThreshold AND a T1 bar starts on this chart bar
Short: low < bottom of any BullOB
Long: high > top of any BearOB
Long: high >= bottom AND low <= top of any BullOB
Short: high >= bottom AND low <= top of any BearOB