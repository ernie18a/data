Long: argmin(low, lookback, bars starting one bar ago) = bar 2 AND high[2] > high[1] AND low[2] < low[1]
Short: argmax(high, lookback, bars starting two bars ago) = bar 2 AND high[2] > high[1] AND low[2] < low[1]
Long: argmin(low, lookback, bars starting one bar ago) = bar 1 AND high[1] > high[2] AND low[1] < low[2]
Short: argmax(high, lookback, bars starting one bar ago) = bar 1 AND high[2] <= high[1] AND low[2] > low[1]
Calculation: CandleRange = high - low
Long: CandleRange[1] / (high[1] - close[1]) >= ratio parameter AND CandleRange[1] / (high[1] - open[1]) >= ratio parameter AND CandleRange[1] / (open[1] - close[1]) >= ratio parameter
Short: CandleRange[1] / (close[1] - low[1]) >= ratio parameter AND CandleRange[1] / (open[1] - low[1]) >= ratio parameter AND CandleRange[1] / (open[1] - close[1]) >= ratio parameter
Long: buy signal AND close crosses above the previous entry level
Short: sell signal AND close crosses below the previous entry level