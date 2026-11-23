Calculation: Resistance = last non-NA value of PivotHigh(high, left bars, right bars) up to the previous bar
Calculation: Support = last non-NA value of PivotLow(low, left bars, right bars) up to the previous bar
Calculation: Phase(length) = 0 if high[length] > Highest(high, length), else 1 if low[length] < Lowest(low, length), else Phase(length)[1]
Calculation: StructureHigh(length) = high[length] at the latest bar where Phase(length) changes from 1 to 0; pivot bar = length bars before that bar
Calculation: StructureLow(length) = low[length] at the latest bar where Phase(length) changes from 0 to 1; pivot bar = length bars before that bar
Calculation: BullBreak(length) = close crosses above StructureHigh(length), first crossing since that level was set
Calculation: BearBreak(length) = close crosses below StructureLow(length), first crossing since that level was set
Calculation: InternalBullBreak = close crosses above StructureHigh(shorter length) while StructureHigh(shorter length) != StructureHigh(longer length), first such crossing since that level was set
Calculation: InternalBearBreak = close crosses below StructureLow(shorter length) while StructureLow(shorter length) != StructureLow(longer length), first such crossing since that level was set
Calculation: Volatility = ATR(volatility length) or cumulative sum of true range / chart bar index, per volatility filter
Calculation: AdjHigh = low if high - low >= volatility multiplier * Volatility, else high
Calculation: AdjLow = high if high - low >= volatility multiplier * Volatility, else low
Calculation: InternalBullOBBottom = lowest AdjLow from the pivot bar of StructureHigh(shorter length) through the bar of InternalBullBreak
Calculation: InternalBearOBTop = highest AdjHigh from the pivot bar of StructureLow(shorter length) through the bar of InternalBearBreak
Calculation: SwingBullOBBottom = lowest AdjLow from the pivot bar of StructureHigh(longer length) through the bar of BullBreak(longer length)
Calculation: SwingBearOBTop = highest AdjHigh from the pivot bar of StructureLow(longer length) through the bar of BearBreak(longer length)
Calculation: BarChange = (close - open) / open of the last completed T1 bar, on chart bars taking T1 values
Calculation: GapThreshold = threshold multiplier * cumulative sum of abs(BarChange) over completed T1 bars / chart bar index
Calculation: InternalTrend = 1 after InternalBullBreak, -1 after InternalBearBreak, else InternalTrend[1]
Long: close crosses above Resistance AND (open - low > close - open OR PVO(volume, shorter lookback, longer lookback) > volume threshold)
Short: close crosses below Support AND (open - close < high - open OR PVO(volume, shorter lookback, longer lookback) > volume threshold)
Long: BullBreak(longer length)
Short: BearBreak(longer length)
Long: InternalBullBreak
Short: InternalBearBreak
Long: bearish mitigation price > InternalBearOBTop, for any internal bearish order block not yet mitigated
Short: bullish mitigation price < InternalBullOBBottom, for any internal bullish order block not yet mitigated
Long: bearish mitigation price > SwingBearOBTop, for any swing bearish order block not yet mitigated
Short: bullish mitigation price < SwingBullOBBottom, for any swing bullish order block not yet mitigated
Long: new T1 bar AND T1 low[0] (still-forming bar) > T1 high[2] AND T1 close[1] (last completed bar) > T1 high[2] AND BarChange > GapThreshold
Short: new T1 bar AND T1 high[0] (still-forming bar) < T1 low[2] AND T1 close[1] (last completed bar) < T1 low[2] AND -BarChange > GapThreshold
Long: InternalTrend = 1
Short: InternalTrend != 1
Long: Phase(longer length) changes from 1 to 0 AND StructureHigh(longer length) > StructureHigh(longer length)[1]
Short: Phase(longer length) changes from 1 to 0 AND StructureHigh(longer length) <= StructureHigh(longer length)[1]
Long: Phase(longer length) changes from 0 to 1 AND StructureLow(longer length) >= StructureLow(longer length)[1]
Short: Phase(longer length) changes from 0 to 1 AND StructureLow(longer length) < StructureLow(longer length)[1]