Calculation: Kernel regression = weighted average of close over the lookback, with weight exp(−i² / (2 × (lookback / 2)²)) for each bar i from 0 through the lookback
Calculation: Buy setup count = consecutive bars where close < close 4 bars earlier; reset to 0 when false
Calculation: Sell setup count = consecutive bars where close > close 4 bars earlier; reset to 0 when false
Calculation: Confirmed pivot high/low = a high/low greater/less than the configured number of bars on both sides; becomes available after the right-side bars complete
Calculation: Heikin-Ashi close = (open + high + low + close) / 4; Heikin-Ashi open = (previous Heikin-Ashi open + previous Heikin-Ashi close) / 2, initialized as (open + close) / 2; use same-timeframe Heikin-Ashi bars, with no lookahead
Long: EMA(shorter lookback) > Kernel regression AND previous EMA(shorter lookback) <= previous Kernel regression
Long: Buy setup count = 9
Long: Close crosses above the latest confirmed pivot high
Long: A newly confirmed pivot low > the previous confirmed pivot low AND close > the newly confirmed pivot low
Long: Heikin-Ashi close > max(EMA(shorter lookback), Kernel regression) AND previous Heikin-Ashi close <= previous max(EMA(shorter lookback), Kernel regression) AND Heikin-Ashi close > Heikin-Ashi open AND bar is confirmed
Short: EMA(shorter lookback) < Kernel regression AND previous EMA(shorter lookback) >= previous Kernel regression
Short: Sell setup count = 9
Short: Close crosses below the latest confirmed pivot low
Exit: