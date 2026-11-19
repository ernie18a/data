Calculation: fast average = selected moving average(selected source, shorter lookback)
Calculation: slow average = selected moving average(selected source, longer lookback)
Calculation: higher-timeframe fast average = selected moving average(selected source, shorter lookback, T1 bars; calculated on T1 bars and sampled on chart bars using the last completed T1 bar historically and the still-forming T1 bar in real time)
Calculation: higher-timeframe slow average = selected moving average(selected source, longer lookback, T1 bars; calculated on T1 bars and sampled on chart bars using the last completed T1 bar historically and the still-forming T1 bar in real time)
Calculation: average separation = ABS(fast average - slow average)
Long: fast average > slow average
Short: fast average <= slow average
Long: fast average crosses above slow average AND (higher-timeframe filter is disabled OR higher-timeframe fast average > higher-timeframe slow average) AND (ATR filter is disabled OR average separation >= ATR(ATR lookback) * ATR separation multiplier)
Short: fast average crosses below slow average AND (higher-timeframe filter is disabled OR higher-timeframe fast average <= higher-timeframe slow average) AND (ATR filter is disabled OR average separation >= ATR(ATR lookback) * ATR separation multiplier)
Long: fast average > slow average AND fast average[1] <= slow average[1]
Short: fast average <= slow average AND fast average[1] > slow average[1]