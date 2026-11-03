Calculation: SuperTrend = ATR-based trailing stop with bullish and bearish states
Calculation: Exit favourability score = For the active SuperTrend direction, collect confirmed zigzag pivot highs from bullish runs or pivot lows from bearish runs, using each pivot bar’s context and retaining a rolling history. Context axes are relative volume percentile, time of day (intraday only), and close’s position in the recent high-low range. Divide each active axis into equal-width bins across its range. For each axis, keep matching-direction pivots whose bins on every other active axis match the current bar; score the current bin as 100 × its pivot count / the largest bin count. Average the available axis scores.
Long: SuperTrend changes from bearish to bullish
Short: SuperTrend changes from bullish to bearish
Exit: long, exit favourability score >= 99.999
Exit: short, exit favourability score >= 99.999