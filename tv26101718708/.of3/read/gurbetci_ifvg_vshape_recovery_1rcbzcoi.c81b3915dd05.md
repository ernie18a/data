Calculation: CandleBody = ABS(close - open)
Calculation: SessionOK = kill-zone hard filter is off OR bar datetime is inside the kill-zone session
Calculation: SwingLowLevel = value of the most recent PivotLow(low, swing length, swing length) confirmed by this bar, set to none after any bar where LowSweep is true or close is below it
Calculation: SwingHighLevel = value of the most recent PivotHigh(high, swing length, swing length) confirmed by this bar, set to none after any bar where HighSweep is true or close is above it
Calculation: LowSweep = low < SwingLowLevel AND close > SwingLowLevel
Calculation: HighSweep = high > SwingHighLevel AND close < SwingHighLevel
Calculation: CorrLowAtSwingLow = lowest correlated-instrument low over the last 2 * swing length + 1 bars, taken on the bar where the most recent PivotLow is confirmed
Calculation: CorrHighAtSwingHigh = highest correlated-instrument high over the last 2 * swing length + 1 bars, taken on the bar where the most recent PivotHigh is confirmed
Calculation: PendingLowCISD = after each bar where LowSweep is true, the open of the oldest bar in the run of consecutive bars with close < open that ends at this bar (or at the prior bar if this bar closes above its open), searching at most CISD run limit bars back, or the open of the run's end bar if the run is empty; kept while no more than CISD window bars have passed since that sweep, overwritten by a later LowSweep, and cleared after any bar where LongVShape is true
Calculation: PendingHighCISD = after each bar where HighSweep is true, the open of the oldest bar in the run of consecutive bars with close > open that ends at this bar (or at the prior bar if this bar closes below its open), searching at most CISD run limit bars back, or the open of the run's end bar if the run is empty; kept while no more than CISD window bars have passed since that sweep, overwritten by a later HighSweep, and cleared after any bar where ShortVShape is true
Calculation: LongVShape = PendingLowCISD is set AND close > PendingLowCISD AND CandleBody >= displacement multiple * ATR(high, low, close, ATR length) AND SessionOK = true
Calculation: ShortVShape = PendingHighCISD is set AND close < PendingHighCISD AND CandleBody >= displacement multiple * ATR(high, low, close, ATR length) AND SessionOK = true
Calculation: BullISupport = bearish FVG zones formed on a bar where high < low[2] AND low[2] - high >= FVG width multiple * ATR at that bar (top = low[2], bottom = high), that a later bar pushed above top with close (or high in wick inversion mode) and that have not since had a close below bottom or a bar with low <= top AND close > top after that inversion bar
Calculation: BearISupply = bullish FVG zones formed on a bar where low > high[2] AND low - high[2] >= FVG width multiple * ATR at that bar (bottom = high[2], top = low), that a later bar pushed below bottom with close (or low in wick inversion mode) and that have not since had a close above top or a bar with high >= bottom AND close < bottom after that inversion bar
Calculation: LongIFVGRetest = some zone in BullISupport as of the previous bar has low <= top AND close > top
Calculation: ShortIFVGRetest = some zone in BearISupply as of the previous bar has high >= bottom AND close < bottom
Long: LowSweep = true
Long: LowSweep = true AND correlated-instrument low > CorrLowAtSwingLow
Long: LongVShape = true
Long: LongIFVGRetest = true
Long: LongIFVGRetest = true AND bars since LongVShape was last true <= confirmation window AND SessionOK = true
Short: HighSweep = true
Short: HighSweep = true AND correlated-instrument high < CorrHighAtSwingHigh
Short: ShortVShape = true
Short: ShortIFVGRetest = true
Short: ShortIFVGRetest = true AND bars since ShortVShape was last true <= confirmation window AND SessionOK = true