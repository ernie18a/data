Long: D1 high of bar #2 > D1 high of bar #1 AND chart-timeframe high of bar #2 > chart-timeframe high of bar #1 AND no open long position
Short: D1 low of bar #2 < D1 low of bar #1 AND chart-timeframe low of bar #2 < chart-timeframe low of bar #1 AND (position-check filter disabled OR no open short position)
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance