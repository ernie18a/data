Calculation: AbnormalRange = high[1] - low[1] > multiplier * average(high[n] - low[n], n = 2 to lookback + 1)
Long: AbnormalRange AND close[1] > open[1] AND close[1] - open[1] > body_fraction * (high[1] - low[1])
Short: AbnormalRange AND close[1] < open[1] AND open[1] - close[1] > body_fraction * (high[1] - low[1])