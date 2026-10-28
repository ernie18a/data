Calculation: Kernel regression = weighted average of the current and prior closes over a lookback, with each bar weighted by exp(−i² / (2 × (lookback / 2)²)), where i is bars ago
Calculation: Buy setup count = consecutive bars with close < close four bars earlier; reset to zero when false
Calculation: Sell setup count = consecutive bars with close > close four bars earlier; reset to zero when false
Long: EMA(9) crosses above kernel regression
Long: Buy setup count = 9
Long: Heikin-Ashi close crosses above the higher of EMA(9) and kernel regression AND Heikin-Ashi close > Heikin-Ashi open AND bar is confirmed
Long: A confirmed pivot low is higher than the preceding confirmed pivot low AND close > the latest pivot low
Long: Close crosses above the latest confirmed pivot high
Short: EMA(9) crosses below kernel regression
Short: Sell setup count = 9
Short: Close crosses below the latest confirmed pivot low
