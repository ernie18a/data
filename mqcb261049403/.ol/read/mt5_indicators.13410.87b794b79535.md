Calculation: TSI = 100 × the second smoothing of the first-smoothed change in close divided by the second smoothing of the first-smoothed absolute change in close; apply the same first and second smoothing methods and lengths to numerator and denominator.
Calculation: Trigger = TSI from the configured number of bars earlier.
Calculation: Higher-timeframe TSI = TSI calculated from aggregated bars of a higher timeframe, using the bar still forming.
Calculation: Higher-timeframe trigger = Higher-timeframe TSI from the configured number of higher-timeframe bars earlier.
Long: TSI > Trigger OR Higher-timeframe TSI > Higher-timeframe trigger
Short: TSI < Trigger OR Higher-timeframe TSI < Higher-timeframe trigger