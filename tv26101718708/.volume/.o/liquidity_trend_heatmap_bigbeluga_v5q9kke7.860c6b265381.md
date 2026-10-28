Calculation: ATR = average true range over its lookback
Calculation: Trend baseline = EMA of the SMA of close, using the same lookback for both averages
Calculation: Grid bounds = highest high plus ATR and lowest low minus ATR over the volume lookback
Calculation: Grid step = (upper grid bound - lower grid bound) / 26
Calculation: Grid levels = lower grid bound + i × grid step, for i = 1 through 25
Calculation: Volume at a grid level = sum of volume over the current and preceding volume-lookback bars whose hl2 is within half a grid step of that level
Calculation: Relative node volume = volume at the grid level / the greatest volume among all 26 grid levels
Long: close > grid level AND relative node volume ≥ the heatmap threshold AND grid level is not the highest-volume node AND abs(open - grid level), abs(high - grid level), abs(low - grid level), abs(close - grid level), abs(hl2 - grid level), and abs(hlc3 - grid level) are each > 2 × grid step AND (when the trend line is shown) abs(trend baseline - grid level) > grid step
Short: close < grid level AND relative node volume ≥ the heatmap threshold AND grid level is not the highest-volume node AND abs(open - grid level), abs(high - grid level), abs(low - grid level), abs(close - grid level), abs(hl2 - grid level), and abs(hlc3 - grid level) are each > 2 × grid step AND (when the trend line is shown) abs(trend baseline - grid level) > grid step