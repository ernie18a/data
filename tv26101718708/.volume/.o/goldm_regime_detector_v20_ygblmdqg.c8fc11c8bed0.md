Calculation: EMA slope percentage = (current EMA − EMA from the slope lookback bars earlier) ÷ slope lookback ÷ current EMA × 100
Calculation: ATR expansion ratio = short-lookback ATR ÷ longer-lookback ATR
Calculation: ATR percentile = percentage of the preceding rank-lookback bars whose short-lookback ATR is below the current short-lookback ATR
Calculation: ATR percentile change = current ATR percentile − ATR percentile 3 bars earlier
Calculation: Days to expiry = maximum of 0 and the ceiling of calendar days from the bar date to the configured expiry date
Calculation: Defensive trigger = ADX crosses above its no-trend threshold plus a buffer OR ATR percentile change exceeds its threshold OR Bollinger %B crosses above its upper extreme threshold or below its lower extreme threshold
Calculation: Regime 1 = ADX below the no-trend threshold AND ATR percentile is within the configured comfortable-to-extreme range AND ATR expansion ratio is not above its danger threshold AND Bollinger %B is within the configured middle range AND days to expiry exceeds the full-size cutoff AND no event override
Calculation: Regime 2 = ADX at or above the no-trend threshold AND ATR percentile is within the configured comfortable-to-extreme range AND ATR expansion ratio is not above its danger threshold AND days to expiry exceeds the full-size cutoff AND NOT (event override AND ATR percentile is above the comfortable maximum)
Calculation: Regime 3 = NOT defensive trigger AND NOT Regime 1 AND NOT Regime 2
Long: Regime 1 OR Regime 3 OR (Regime 2 AND EMA slope percentage is above its positive direction threshold)
Short: Regime 1 OR Regime 3 OR (Regime 2 AND EMA slope percentage is below its negative direction threshold)
Exit: long or short, defensive trigger OR days to expiry is at or below the force-close threshold