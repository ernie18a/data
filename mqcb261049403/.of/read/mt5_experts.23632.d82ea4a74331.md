Calculation: Weighted close = (high + low + 2 × close) / 4
Calculation: Linearly weighted moving average = the weighted average of weighted close over a lookback, assigning greater weight to more recent bars
Long: current bar open > linearly weighted moving average on the last completed bar
Short: current bar open < linearly weighted moving average on the last completed bar
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance OR current bar open < linearly weighted moving average on the last completed bar
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance OR current bar open > linearly weighted moving average on the last completed bar