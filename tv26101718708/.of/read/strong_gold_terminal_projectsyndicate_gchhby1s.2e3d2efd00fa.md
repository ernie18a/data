Calculation: Timeframe pressure score = mean of six scores: Supertrend direction is +1 for up and -1 for down; EMA score is (number of closes above three EMAs minus 1.5) / 1.5; RSI score is (RSI minus its midpoint) divided by a scale parameter, clipped to [-1, 1]; MACD score is +1 if the histogram is positive and rising, +0.5 if positive and not rising, -1 if nonpositive and falling, otherwise -0.5; ADX score is +min(ADX / scale parameter, 1) if +DI > -DI and its negative otherwise; range-position score is 2 × (close - lowest low) / (highest high - lowest low) - 1, or 0 when the range is zero. The three EMA lookbacks are short, medium and long. Calculate each score on each configured timeframe; for a higher timeframe use its last completed bar, and for a lower timeframe use its last completed intrabar within the chart bar.
Calculation: Composite pressure = weighted mean of the timeframe pressure scores, substituting zero for an unavailable score; weights are equal or greater for longer timeframes.
Calculation: Bullish timeframe count = number of configured timeframes whose pressure score exceeds a positive threshold; bearish timeframe count = number whose pressure score is below the corresponding negative threshold.
Long: Close crosses above the high of the last completed higher-timeframe day OR the high of the last completed higher-timeframe week.
Short: Close crosses below the low of the last completed higher-timeframe day OR the low of the last completed higher-timeframe week.
Long: Close > the high of the last completed higher-timeframe day OR close > the high of the last completed higher-timeframe week.
Short: Close < the low of the last completed higher-timeframe day OR close < the low of the last completed higher-timeframe week.
Long: Chart-timeframe Supertrend changes from down to up.
Short: Chart-timeframe Supertrend changes from up to down.
Long: Chart-timeframe Supertrend direction = up.
Short: Chart-timeframe Supertrend direction = down.
Long: Short EMA > medium EMA AND medium EMA > long EMA.
Short: Short EMA < medium EMA AND medium EMA < long EMA.
Long: Close > long EMA.
Short: Close <= long EMA.
Long: +DI > -DI.
Short: +DI <= -DI.
Long: RSI > its midpoint.
Short: RSI < its midpoint.
Long: Rate of change > 0.
Short: Rate of change <= 0.
Long: Latest confirmed pivot high > preceding confirmed pivot high AND latest confirmed pivot low > preceding confirmed pivot low.
Short: Latest confirmed pivot high <= preceding confirmed pivot high AND latest confirmed pivot low <= preceding confirmed pivot low.
Long: ADX >= trend threshold AND chart-timeframe Supertrend direction = up.
Short: ADX >= trend threshold AND chart-timeframe Supertrend direction = down.
Long: Composite pressure >= positive strong-pressure threshold AND previous composite pressure < that threshold.
Short: Composite pressure <= corresponding negative strong-pressure threshold AND previous composite pressure > that threshold.
Long: Composite pressure >= positive bullish threshold.
Short: Composite pressure <= corresponding negative bearish threshold.
Long: Bullish timeframe count >= bearish timeframe count.
Short: Bearish timeframe count > bullish timeframe count.
Long: Any individual timeframe pressure score > 0 OR the mean score of any one metric across the configured timeframes > 0.
Short: Any individual timeframe pressure score < 0 OR the mean score of any one metric across the configured timeframes < 0.