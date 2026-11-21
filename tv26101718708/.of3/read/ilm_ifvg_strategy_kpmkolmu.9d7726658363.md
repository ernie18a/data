Calculation: ChartPivotHigh = PivotHigh(high, swing length, swing length) on chart bars
Calculation: ChartPivotLow = PivotLow(low, swing length, swing length) on chart bars
Calculation: HtfPivotHigh = PivotHigh(high, swing length, swing length) on T1 bars, last completed T1 bar
Calculation: HtfPivotLow = PivotLow(low, swing length, swing length) on T1 bars, last completed T1 bar
Calculation: SellLiquidityLevel = most recent non-NA value of (HtfPivotLow if HTF liquidity option is on, else ChartPivotLow)
Calculation: BuyLiquidityLevel = most recent non-NA value of (HtfPivotHigh if HTF liquidity option is on, else ChartPivotHigh)
Calculation: SellSideSweep = low < SellLiquidityLevel AND close > SellLiquidityLevel
Calculation: BuySideSweep = high > BuyLiquidityLevel AND close < BuyLiquidityLevel
Calculation: LongTargetLevel = most recent non-NA ChartPivotHigh confirmed after the most recent SellSideSweep bar, otherwise NA
Calculation: ShortTargetLevel = most recent non-NA ChartPivotLow confirmed after the most recent BuySideSweep bar, otherwise NA
Calculation: StructureHigh(S) = pivot high of S when non-NA on the current bar (ChartPivotHigh for chart bars, HtfPivotHigh for T1 bars), otherwise max(previous StructureHigh(S), previous close of S)
Calculation: StructureLow(S) = pivot low of S when non-NA on the current bar (ChartPivotLow for chart bars, HtfPivotLow for T1 bars), otherwise min(previous StructureLow(S), previous close of S)
Calculation: StructureTrend(S) = 1 on bars where close of S > StructureHigh(S), -1 on bars where close of S < StructureLow(S), otherwise previous StructureTrend(S)
Calculation: PremiumDiscountMid = (highest high + lowest low) / 2 over bars of the most recent premium/discount session, unchanged on bars outside that session
Calculation: BearGap = (lower = high[1], upper = low[2]) on the most recent bar where (max(open[1], close[1]) if body gap option, else high[1]) < low[2] AND high[1] - low[1] >= ATR(atr length) * displacement multiple, otherwise unchanged
Calculation: BullGap = (lower = high[2], upper = low[1]) on the most recent bar where (min(open[1], close[1]) if body gap option, else low[1]) > high[2] AND high[1] - low[1] >= ATR(atr length) * displacement multiple, otherwise unchanged
Calculation: LongZone = BearGap on each bar where close > BearGap lower, otherwise unchanged
Calculation: ShortZone = BullGap on each bar where close < BullGap lower, otherwise unchanged
Long: bar time within session window AND ATR(atr length) / close * 100 >= minimum ATR percent AND (structure filter disabled OR StructureTrend(chart bars) = 1) AND (HTF expansion filter disabled OR StructureTrend(T1 bars, last completed bar) = 1) AND (premium/discount filter disabled OR close < PremiumDiscountMid) AND high >= LongZone upper AND low <= LongZone lower AND bars since most recent SellSideSweep <= max bars after sweep AND no long entry from the most recent SellSideSweep bar up to the previous bar AND LongTargetLevel is not NA AND close > open
Short: bar time within session window AND ATR(atr length) / close * 100 >= minimum ATR percent AND (structure filter disabled OR StructureTrend(chart bars) = -1) AND (HTF expansion filter disabled OR StructureTrend(T1 bars, last completed bar) = -1) AND (premium/discount filter disabled OR close > PremiumDiscountMid) AND high >= ShortZone lower AND low <= ShortZone upper AND bars since most recent BuySideSweep <= max bars after sweep AND no short entry from the most recent BuySideSweep bar up to the previous bar AND ShortTargetLevel is not NA AND close < open
Long: close > StructureHigh(chart bars)
Short: close < StructureLow(chart bars)
Long: last completed T1 bar close > StructureHigh(T1 bars)
Short: last completed T1 bar close < StructureLow(T1 bars)
Long: close > BearGap lower
Short: close < BullGap lower
Long: SellSideSweep
Short: BuySideSweep
Exit: long, low <= (low of the SellSideSweep bar that preceded the entry) - one tick
Exit: long, high >= LongTargetLevel at entry
Exit: long, partial targets enabled AND high >= entry price + (LongTargetLevel at entry - entry price) * TP1 fraction
Exit: short, high >= (high of the BuySideSweep bar that preceded the entry) + one tick
Exit: short, low <= ShortTargetLevel at entry
Exit: short, partial targets enabled AND low <= entry price + (ShortTargetLevel at entry - entry price) * TP1 fraction