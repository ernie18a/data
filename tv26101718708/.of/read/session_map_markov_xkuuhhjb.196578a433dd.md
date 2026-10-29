Calculation: Opening-range high/low = highest high / lowest low from the regular-hours open through the configured opening-range duration.
Calculation: Initial-balance high/low = highest high / lowest low from the regular-hours open through the configured initial-balance duration.
Calculation: Anchored VWAP and standard deviation = volume-weighted mean and standard deviation of hlc3 since the selected session or daily anchor; use equal weights when volume is unavailable.
Long: During regular hours, after the opening range is complete, the first close above its high of the session; OR low VWAP band tag: low ≤ anchored VWAP − 2 × standard deviation.
Long: During regular hours, after the initial balance is complete, the first close above its high of the session.
Short: During regular hours, after the opening range is complete, the first close below its low of the session; OR high VWAP band tag: high ≥ anchored VWAP + 2 × standard deviation.
Short: During regular hours, after the initial balance is complete, the first close below its low of the session.