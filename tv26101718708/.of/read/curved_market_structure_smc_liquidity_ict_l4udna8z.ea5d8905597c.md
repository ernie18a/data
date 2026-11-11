Calculation: Curve midpoint = EMA of EMA(close, smoothing length) using a second length equal to the rounded half of the smoothing length.
Calculation: Curve deviation = EMA of the standard deviation of close over the smoothing length, using the same smoothing length, multiplied by a deviation multiplier. Upper curve = curve midpoint + curve deviation; lower curve = curve midpoint - curve deviation.
Calculation: Body fraction = abs(close - open) / (high - low) when high > low, otherwise 0.
Calculation: Active pivot high = the most recently confirmed pivot high, using equal left and right lookbacks, replaced when a newer pivot high is confirmed and cleared after an upward close crossover. Active pivot low = the most recently confirmed pivot low, using the same lookbacks, replaced when a newer pivot low is confirmed and cleared after a downward close crossover. A crossover compares the current close with the current active pivot and the previous close with the previous bar's active pivot.
Calculation: Each sweep direction has an independent last-signal bar index, initialized to -999 and updated whenever its corresponding sweep decision occurs. Bar indices start at 0.
Long: (previous low <= previous lower curve OR current low <= current lower curve) AND RSI(close) > buy momentum threshold AND close > open AND current bar index - last long-sweep bar index >= cooldown.
Short: (previous high >= previous upper curve OR current high >= current upper curve) AND RSI(close) < sell momentum threshold AND close < open AND current bar index - last short-sweep bar index >= cooldown.
Long: Body fraction >= consolidation threshold AND close > open.
Short: Body fraction >= consolidation threshold AND close <= open.
Long: Active pivot high exists AND close crosses above active pivot high.
Short: Active pivot low exists AND close crosses below active pivot low.