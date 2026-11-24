Calculation: fast EMA = EMA(close, shorter lookback)
Calculation: slow EMA = EMA(close, longer lookback)
Calculation: active BSL levels = untaken confirmed Pivot High(high, swing lookback, swing lookback) levels, retaining at most the maximum number of most recent levels per side; a level is taken when close is above it or when high is above it and close is at or below it
Calculation: active SSL levels = untaken confirmed Pivot Low(low, swing lookback, swing lookback) levels, retaining at most the maximum number of most recent levels per side; a level is taken when close is below it or when low is below it and close is at or above it
Long: fast EMA crosses above slow EMA
Short: fast EMA crosses below slow EMA
Long: fast EMA > slow EMA AND low <= fast EMA AND close > fast EMA AND NOT (fast EMA crosses above slow EMA)
Short: fast EMA < slow EMA AND high >= fast EMA AND close < fast EMA AND NOT (fast EMA crosses below slow EMA)
Long: fast EMA > slow EMA AND low <= slow EMA AND close > slow EMA
Short: fast EMA < slow EMA AND high >= slow EMA AND close < slow EMA
Long: fast EMA > slow EMA AND close > fast EMA AND close[1] <= fast EMA[1]
Short: fast EMA < slow EMA AND close < fast EMA AND close[1] >= fast EMA[1]
Long: close[2] < open[2] AND close[1] > open[1] AND low[1] > low[2] AND close[1] < open[2] AND close > high[1] AND close > open
Short: close[2] > open[2] AND close[1] < open[1] AND high[1] < high[2] AND close[1] > open[2] AND close < low[1] AND close < open
Long: low < an active SSL level AND close >= that level
Short: high > an active BSL level AND close <= that level