Calculation: Strat bar type = inside if high <= high[1] AND low >= low[1]; else outside if high > high[1] AND low < low[1]; else bullish if close > open; else bearish if close < open; else neutral.
Calculation: T midpoint = (high[1] + low[1]) / 2, from the last completed T bar and carried to chart bars.
Calculation: Session open = open of the first chart bar in regular trading hours each session.
Long: Strat bar type = bullish on a chart bar OR on any T1, T2, T3, or T4 bar displayed in the table, calculated on that timeframe and mapped to chart bars; the current T bar may still be forming and the prior displayed bars are completed.
Short: Strat bar type = bearish on a chart bar OR on any T1, T2, T3, or T4 bar displayed in the table, calculated on that timeframe and mapped to chart bars; the current T bar may still be forming and the prior displayed bars are completed.
Long: For each of T1, T2, T3, and T4, on chart bars, close >= T midpoint.
Short: For each of T1, T2, T3, and T4, on chart bars, close < T midpoint.
Long: During regular trading hours, close >= session open.
Short: During regular trading hours, close < session open.