Calculation: Candle body size in pips = absolute difference between the candle's close and open, converted to pips
Long: Long position count == 0 AND close[1] > high[2] AND close[2] < open[2] AND close[1] > open[1] AND candle body size[1] >= minimum body size AND candle body size[1] <= maximum body size
Short: Short position count == 0 AND low[1] < low[2] AND close[2] < open[2] AND close[1] < open[1] AND candle body size[1] >= minimum body size AND candle body size[1] <= maximum body size
Exit: Long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: Short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance