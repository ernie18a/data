Calculation: Confirmed price levels = chart-timeframe highs and lows at confirmed extrema of a Gaussian-weighted moving average of close, or at confirmed raw price pivots
Calculation: Breakout displacement = ATR × configurable displacement multiplier
Calculation: Relative volume = volume / moving average of volume
Calculation: Trade risk = ATR at signal × configurable stop multiplier
Calculation: Target = entry price ± trade risk × configurable R multiple
Long: close > an unbroken resistance level + breakout displacement AND previous close ≤ that level AND (relative volume ≥ threshold OR volume is unavailable) OR an upward break retests within a configurable bar window, with low within an ATR-based tolerance of the level, close above the level, and no prior false break or retest
Short: close < an unbroken support level − breakout displacement AND previous close ≥ that level AND (relative volume ≥ threshold OR volume is unavailable) OR a downward break retests within a configurable bar window, with high within an ATR-based tolerance of the level, close below the level, and no prior false break or retest
Exit: long, low ≤ entry price − trade risk OR high ≥ target OR bars since entry ≥ configurable holding horizon
Exit: short, high ≥ entry price + trade risk OR low ≤ target OR bars since entry ≥ configurable holding horizon