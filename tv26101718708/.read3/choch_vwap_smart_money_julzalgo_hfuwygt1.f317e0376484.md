Calculation: LastPivotHigh = last non-na value of PivotHigh(high, pivot length, pivot length)
Calculation: LastPivotLow = last non-na value of PivotLow(low, pivot length, pivot length)
Calculation: UpBreak = if break confirmation mode is close then close crosses above LastPivotHigh, else high > LastPivotHigh AND high[1] <= LastPivotHigh
Calculation: DownBreak = if break confirmation mode is close then close crosses below LastPivotLow, else low < LastPivotLow AND low[1] >= LastPivotLow
Calculation: HighBroken = PivotHigh(high, pivot length, pivot length) is na AND (HighBroken[1] OR UpBreak)
Calculation: LowBroken = PivotLow(low, pivot length, pivot length) is na AND (LowBroken[1] OR DownBreak)
Calculation: StructureTrend = bearish if DownBreak AND NOT LowBroken[1], else bullish if UpBreak AND NOT HighBroken[1], else StructureTrend[1]
Long: internal CHoCH enabled AND UpBreak AND NOT HighBroken[1] AND StructureTrend[1] = bearish
Short: internal CHoCH enabled AND DownBreak AND NOT LowBroken[1] AND StructureTrend[1] = bullish