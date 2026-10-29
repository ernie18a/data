Calculation: Applied price = configured price derived from the bar’s open, high, low, and close.
Calculation: First smoothing = smooth the applied price using the configured first smoothing method and lookback.
Calculation: Second smoothing = smooth the first smoothing using the configured second smoothing method and lookback.
Calculation: DEMA line = 2 × first smoothing − second smoothing.
Calculation: Higher-timeframe values = calculate the same smoothed values and DEMA line on a timeframe equal to or higher than the chart timeframe, using the higher-timeframe bar still forming; sample at the first chart bar of that higher-timeframe bar and carry forward until the next one.
Long: DEMA line > first smoothing OR first smoothing > second smoothing OR higher-timeframe DEMA line > higher-timeframe first smoothing OR higher-timeframe first smoothing > higher-timeframe second smoothing
Short: DEMA line < first smoothing OR first smoothing < second smoothing OR higher-timeframe DEMA line < higher-timeframe first smoothing OR higher-timeframe first smoothing < higher-timeframe second smoothing