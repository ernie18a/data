Calculation: Higher-timeframe open = open of the current, still-forming bar from a higher timeframe.
Calculation: Reaction-band half-width = the greater of one minimum tick and the selected width: chart-timeframe ATR × multiplier, absolute higher-timeframe open × percentage, or minimum tick × tick count.
Calculation: Accepted above = closes above the higher-timeframe open plus the reaction-band half-width for the configured number of consecutive chart-timeframe bars; the streak resets at the start of each higher-timeframe period.
Calculation: Accepted below = closes below the higher-timeframe open minus the reaction-band half-width for the configured number of consecutive chart-timeframe bars; the streak resets at the start of each higher-timeframe period.
Calculation: New acceptance above = accepted above becomes true on this bar after being false on the prior bar, excluding the first chart-timeframe bar of a new higher-timeframe period.
Calculation: New acceptance below = accepted below becomes true on this bar after being false on the prior bar, excluding the first chart-timeframe bar of a new higher-timeframe period.
Calculation: Recent band interaction = a chart-timeframe bar's high-low range intersects the reaction band within the configured chart-timeframe lookback.
Long: New acceptance above AND recent band interaction
Short: New acceptance below AND recent band interaction