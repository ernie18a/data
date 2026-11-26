Calculation: HighLevel = most recent confirmed PivotHigh(high, structure swing lookback, structure swing lookback) on T1 bars, taken from the last completed T1 bar, cleared once a last completed T1 close exceeds it
Calculation: LowLevel = most recent confirmed PivotLow(low, structure swing lookback, structure swing lookback) on T1 bars, taken from the last completed T1 bar, cleared once a last completed T1 close is below it
Calculation: StructTrend = 1 if last completed T1 close > HighLevel, -1 if last completed T1 close < LowLevel, otherwise StructTrend[1]
Long: StructTrend = 1
Short: StructTrend = -1
Calculation: PivotHighLevel = most recent confirmed PivotHigh(high, sweep lookback, sweep lookback)
Calculation: PivotLowLevel = most recent confirmed PivotLow(low, sweep lookback, sweep lookback)
Calculation: LowSweepBar = low < PivotLowLevel AND close > PivotLowLevel AND open > PivotLowLevel AND low == Lowest(low, sweep lookback) AND Lowest(close, sweep lookback) >= PivotLowLevel
Calculation: HighSweepBar = high > PivotHighLevel AND close < PivotHighLevel AND open < PivotHighLevel AND high == Highest(high, sweep lookback) AND Highest(close, sweep lookback) <= PivotHighLevel
Calculation: LowSweep = LowSweepBar[sweep confirmation delay] AND close > PivotLowLevel AND close[1] > PivotLowLevel[1] AND close[2] > PivotLowLevel[2] AND bars since previous LowSweep >= sweep cooldown
Calculation: HighSweep = HighSweepBar[sweep confirmation delay] AND close < PivotHighLevel AND close[1] < PivotHighLevel[1] AND close[2] < PivotHighLevel[2] AND bars since previous HighSweep >= sweep cooldown
Long: LowSweep = true
Short: HighSweep = true