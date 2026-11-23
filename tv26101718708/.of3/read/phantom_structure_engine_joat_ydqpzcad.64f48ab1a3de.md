Calculation: Ready = bar index >= max(warmup factor * (pivot left bars + pivot right bars), warmup minimum)
Calculation: LastSwingHigh = most recent non-NA PivotHigh(high, pivot left bars, pivot right bars) up to and including this bar
Calculation: PreviousSwingHigh = second most recent non-NA PivotHigh(high, pivot left bars, pivot right bars) up to and including this bar
Calculation: LastSwingLow = most recent non-NA PivotLow(low, pivot left bars, pivot right bars) up to and including this bar
Calculation: PreviousSwingLow = second most recent non-NA PivotLow(low, pivot left bars, pivot right bars) up to and including this bar
Calculation: UpRun = consecutive bars ending at this bar, counting only bars from the bar that confirmed LastSwingHigh onward, with close > LastSwingHigh
Calculation: DownRun = consecutive bars ending at this bar, counting only bars from the bar that confirmed LastSwingLow onward, with close < LastSwingLow
Calculation: UpBOS = Ready AND UpRun >= confirmation closes AND no UpBOS on an earlier bar since LastSwingHigh was confirmed
Calculation: DownBOS = Ready AND DownRun >= confirmation closes AND no DownBOS on an earlier bar since LastSwingLow was confirmed
Calculation: StructureDirection = +1 if the most recent of UpBOS and DownBOS is UpBOS, -1 if it is DownBOS, 0 if neither has occurred
Calculation: FundingCandle = True Range > ATR(ATR length) * funding range multiple AND volume > SMA(volume, volume SMA length) * funding volume multiple
Long: UpBOS
Short: DownBOS
Long: low < LastSwingLow AND close > LastSwingLow AND Ready
Short: high > LastSwingHigh AND close < LastSwingHigh AND Ready
Long: low > high[2] AND Ready
Short: high < low[2] AND Ready
Long: FundingCandle AND StructureDirection == 1
Short: FundingCandle AND StructureDirection == -1
Long: PivotHigh(high, pivot left bars, pivot right bars) is not NA AND LastSwingHigh > PreviousSwingHigh
Short: PivotHigh(high, pivot left bars, pivot right bars) is not NA AND LastSwingHigh <= PreviousSwingHigh
Long: PivotLow(low, pivot left bars, pivot right bars) is not NA AND LastSwingLow > PreviousSwingLow
Short: PivotLow(low, pivot left bars, pivot right bars) is not NA AND LastSwingLow <= PreviousSwingLow