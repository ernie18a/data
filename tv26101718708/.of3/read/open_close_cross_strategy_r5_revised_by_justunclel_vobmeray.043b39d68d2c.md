Calculation: chart close average = selected MA(close[delay], lookback, MA type, LSMA offset, ALMA sigma, ALMA offset) on chart bars
Calculation: alternate close average = selected MA(close[delay], same parameters) on the current, still-forming bar of T1 when alternate resolution is enabled, with values sampled on chart bars; otherwise calculate on chart bars
Calculation: alternate open average = selected MA(open[delay], same parameters) on the current, still-forming bar of T1 when alternate resolution is enabled, with values sampled on chart bars; otherwise calculate on chart bars
Long: alternate close average crosses above alternate open average AND the trade selector permits long entries
Short: alternate close average crosses below alternate open average AND the trade selector permits short entries
Long: alternate close average > alternate open average
Short: alternate close average <= alternate open average
Long: bar coloring is enabled AND chart close average > alternate open average
Short: bar coloring is enabled AND chart close average <= alternate open average
Exit: long, (alternate close average crosses below alternate open average AND the trade selector disables short entries) OR (stop-loss is enabled AND low <= entry price - stop-loss distance) OR (target-profit is enabled AND high >= entry price + target-profit distance)
Exit: short, (alternate close average crosses above alternate open average AND the trade selector disables long entries) OR (stop-loss is enabled AND high >= entry price + stop-loss distance) OR (target-profit is enabled AND low <= entry price - target-profit distance)