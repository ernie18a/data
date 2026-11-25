Calculation: Short trigger level = max(previous bar's post-reset short trigger level, Lowest(low, lookback)); reset to Lowest(low, lookback) after a bar where LWMA(high, lookback) < this level and close < low[1]
Calculation: Long trigger level = min(previous bar's post-reset long trigger level, Highest(high, lookback)); reset to Highest(high, lookback) after a bar where LWMA(low, lookback) > this level and close > high[1]
Calculation: Direction = bullish if LWMA(low, lookback) > Long trigger level AND close > high[1]; otherwise bearish if LWMA(high, lookback) < Short trigger level AND close < low[1]; otherwise the previous direction; initial direction is neutral
Long: Direction = bullish
Short: Direction = bearish