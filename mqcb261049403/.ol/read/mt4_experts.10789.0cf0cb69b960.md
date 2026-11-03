Calculation: Percent above daily low = (daily close − daily low) / daily low × 100, using the higher-timeframe daily bar still forming
Calculation: Percent below daily high = (daily high − daily close) / daily high × 100, using the higher-timeframe daily bar still forming
Calculation: Long-position average entry price = sum(entry price × lot size) / sum(lot size)
Calculation: Short-position average entry price = sum(entry price × lot size) / sum(lot size)
Long: Percent below daily high ≤ percentage threshold AND previous completed chart bar close > open AND no short position exists AND (no long position exists OR current ask < lowest long entry price − averaging distance + spread)
Short: Percent above daily low ≤ percentage threshold AND previous completed chart bar close < open AND no long position exists AND (no short position exists OR current bid > highest short entry price + averaging distance + spread)
Exit: long, current price ≥ entry price + spread + take-profit distance when one long order exists OR current price ≥ lot-weighted average long entry price + profit offset when at least two long orders exist
Exit: short, current price ≤ entry price − spread − take-profit distance when one short order exists OR current price ≤ lot-weighted average short entry price − profit offset when at least two short orders exist