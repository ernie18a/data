Long: close > open AND close > max(close[2], open[2]) AND low[1] < low[2] AND high[1] < high[2]
Short: close < open AND close < min(close[2], open[2]) AND low[1] > low[2] AND high[1] > high[2]
Exit: long, low <= entry-bar low * (1 - stop-loss fraction) OR high >= entry-bar high * (1 + take-profit fraction)
Exit: short, high >= entry-bar high * (1 + stop-loss fraction) OR low <= entry-bar low * (1 - take-profit fraction)