Calculation: Fast and slow moving averages = configured moving averages of chart-bar price; fast lookback is shorter than slow lookback.
Calculation: Main resistance/support = latest pivot high/low of chart-bar highs/lows, confirmed after the left lookback and shorter right lookback. When higher-timeframe levels are enabled, calculate on that higher timeframe and use only its last completed bar.
Long: First bar with the average of high, low, and close above both moving averages, and (if enabled) open above both; if enabled, the ribbon direction and fast-average slope filters must also pass.
Short: First bar with the average of high, low, and close below both moving averages, and (if enabled) open below both; if enabled, the ribbon direction and fast-average slope filters must also pass.
Long: Fast moving average crosses above slow moving average.
Short: Fast moving average crosses below slow moving average.
Long: Fast moving average is above slow moving average and close is above the previous close, on the first such bar after the uptrend begins.
Short: Fast moving average is below slow moving average and close is below the previous close, on the first such bar after the downtrend begins.
Long: Previous close is at or below main resistance and current close is above main resistance by at least the configured breakout margin.
Short: Previous close is at or above main support and current close is below main support by at least the configured breakout margin.
Long: Main resistance has previously broken upward, current low is within the configured tolerance of that level, and current close is above it.
Short: Main support has previously broken downward, current high is within the configured tolerance of that level, and current close is below it.
Long: Current low is below main support by more than the configured tolerance and current close is above main support.
Short: Current high is above main resistance by more than the configured tolerance and current close is below main resistance.
Exit: Long, a qualifying long-signal streak was active on the previous bar and is no longer active on the current bar.
Exit: Short, a qualifying short-signal streak was active on the previous bar and is no longer active on the current bar.