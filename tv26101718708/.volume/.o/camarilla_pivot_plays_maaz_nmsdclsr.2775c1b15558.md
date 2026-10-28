Calculation: Prior-session pivots = use the prior completed extended-hours session’s close, high, and low when its range extends beyond the regular-session range by the volatility threshold; otherwise use the prior completed regular-session close, high, and low.
Calculation: R3 = pivot close + 1.1 × (pivot high − pivot low) / 4
Calculation: R4 = pivot close + 1.1 × (pivot high − pivot low) / 2
Calculation: S3 = pivot close − 1.1 × (pivot high − pivot low) / 4
Calculation: S4 = pivot close − 1.1 × (pivot high − pivot low) / 2
Calculation: Relative volume = bar volume / its moving average volume
Long: bar low crosses below S3 AND bar close > S3
Long: bar high crosses above R3 AND bar close < R3
Long: bar close crosses above R4 AND (volume filter disabled OR relative volume ≥ threshold) AND bar close > bar open
Short: bar high crosses above R3 AND bar close < R3
Short: bar close crosses below S4 AND (volume filter disabled OR relative volume ≥ threshold) AND bar close < bar open