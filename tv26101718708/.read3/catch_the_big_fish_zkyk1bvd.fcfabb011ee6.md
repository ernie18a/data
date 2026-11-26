Long: volume > SMA(volume, lookback) * multiplier AND close < open
Short: volume > SMA(volume, lookback) * multiplier AND close > open
Calculation: long breakout level = high if volume > SMA(volume, lookback) * multiplier AND close < open; otherwise prior long breakout level if positive, otherwise 0
Calculation: short breakout level = low if volume > SMA(volume, lookback) * multiplier AND close > open; otherwise prior short breakout level if positive, otherwise 0
Long: long breakout level > 0 AND close[1] >= long breakout level AND low[1] <= long breakout level AND close >= close[1] AND close[1] >= open[1]
Short: short breakout level > 0 AND close[1] <= short breakout level AND high[1] >= short breakout level AND close <= close[1] AND close[1] <= open[1]
Calculation: long stop = low[1] on the long-entry bar
Calculation: short stop = high[1] on the short-entry bar
Exit: long, low <= long stop
Exit: short, high >= short stop