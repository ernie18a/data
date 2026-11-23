Calculation: OpeningRangeHigh = highest high over the bars of the most recent opening range window
Calculation: OpeningRangeLow = lowest low over the bars of the most recent opening range window
Calculation: UpBreakPrice = high if WickBreakout, else close
Calculation: DownBreakPrice = low if WickBreakout, else close
Calculation: FirstBreak = none until the first bar inside the trading-day window after the most recent opening range window where UpBreakPrice > OpeningRangeHigh or DownBreakPrice < OpeningRangeLow; then up if that bar has UpBreakPrice > OpeningRangeHigh, else down
Long: UpBreakPrice > OpeningRangeHigh AND FirstBreak[1] = none AND bar time is inside the trading-day window
Short: DownBreakPrice < OpeningRangeLow AND UpBreakPrice <= OpeningRangeHigh AND FirstBreak[1] = none AND bar time is inside the trading-day window
Exit: long, close < OpeningRangeHigh AND max(high) over bars after the first break through the previous bar < OpeningRangeHigh + (OpeningRangeHigh - OpeningRangeLow) * Target1Multiple AND bar time is inside the trading-day window
Exit: short, close > OpeningRangeLow AND min(low) over bars after the first break through the previous bar > OpeningRangeLow - (OpeningRangeHigh - OpeningRangeLow) * Target1Multiple AND bar time is inside the trading-day window