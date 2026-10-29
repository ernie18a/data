Calculation: Smoothed price = close, or its exponential moving average over a smoothing lookback when smoothing is enabled
Calculation: Trend midpoint = linear regression of smoothed price over a lookback
Calculation: Upper anchor = highest smoothed price over the trend-anchor lookback
Calculation: Lower anchor = lowest smoothed price over the trend-anchor lookback
Calculation: Extension z-score = (smoothed price − its exponential moving average) / its standard deviation, using the extension lookback
Calculation: Higher-timeframe volatility rank = percentile rank of the 20-bar exponential moving average of higher-timeframe close standard deviation, over a longer lookback; use the higher-timeframe bar still forming
Calculation: Upper and lower bands = sort the two values (0.7 × upper anchor + 0.3 × trend midpoint − upper width) and (0.7 × lower anchor + 0.3 × trend midpoint + lower width), where upper width = upper multiplier × (1 − logistic(z-score) × upper compression) × ATR(trend-anchor lookback) × (1 + 0.5 × volatility rank / 100), and lower width uses the lower multiplier and logistic(−z-score) × lower compression
Calculation: Adaptive centerline = 10-bar exponential moving average of the midpoint of the upper and lower bands
Calculation: Trend-stop level = highest close over the lookback whose absolute Pearson correlation between log(close) and time is greatest, among the available candidate lookbacks, multiplied by (1 − trend-stop percentage)
Calculation: Event-stop level = entry price × (1 − event-stop percentage)
Long: Previous regime state is bearish AND (signal trigger is Fast Centerline Break and smoothed price crosses above the adaptive centerline OR signal trigger is Conservative and smoothed price has crossed above the adaptive centerline within the last three bars AND is above it AND the trend midpoint is rising OR signal trigger is Band Reversal and smoothed price crosses above the lower band) AND (bar is confirmed when close confirmation is enabled)
Long: Previous close is at or below the trend-stop level AND current close is above it
Long: Previous close is at or below the event-stop level AND current close is above it
Short: Previous regime state is bullish AND (signal trigger is Fast Centerline Break and smoothed price crosses below the adaptive centerline OR signal trigger is Conservative and smoothed price has crossed below the adaptive centerline within the last three bars AND is below it AND the trend midpoint is falling OR signal trigger is Band Reversal and smoothed price crosses below the upper band) AND (bar is confirmed when close confirmation is enabled)
Exit: long position, previous close is above the trend-stop level AND current close is at or below it
Exit: long position, previous close is above the event-stop level AND current close is at or below it