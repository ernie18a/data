Calculation: MACD histogram = difference between the shorter-period and longer-period exponential moving averages of close, minus the simple moving average of that difference.
Calculation: Histogram comparison base = start with the bar before the last completed bar; while its histogram differs from the last completed bar's histogram by less than a tolerance and the direction of each examined one-bar change matches the initial direction, move back one bar.
Long: Current bar's calendar day differs from the previous bar's calendar day AND last completed bar's histogram < histogram at the comparison base - tolerance.
Short: Current bar's calendar day differs from the previous bar's calendar day AND last completed bar's histogram > histogram at the comparison base + tolerance.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.