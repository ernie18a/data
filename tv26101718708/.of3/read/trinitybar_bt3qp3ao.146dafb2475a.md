Calculation: VWAP = cumulative sum(((high + low + close) / 3) * volume) / cumulative sum(volume)
Long: ((open[2] <= low[2] + (high[2] - low[2]) / 3 AND close[2] >= high[2] - (high[2] - low[2]) / 3) OR (open[2] >= high[2] - (high[2] - low[2]) / 3 AND close[2] >= high[2] - (high[2] - low[2]) / 3)) AND low[3] < low[2] AND low[3] < VWAP AND close[2] > VWAP
Short: ((open[2] <= low[2] + (high[2] - low[2]) / 3 AND close[2] <= low[2] + (high[2] - low[2]) / 3) OR (open[2] >= high[2] - (high[2] - low[2]) / 3 AND close[2] <= low[2] + (high[2] - low[2]) / 3)) AND high[3] > high[2] AND high[3] > VWAP AND close[2] < VWAP
Exit: long, high >= high[2] + take-profit multiplier * (high[2] - low[3]) OR low <= low[2]
Exit: short, low <= low[2] - take-profit multiplier * (high[3] - low[2]) OR high >= high[2]