Calculation: Bar volume delta = volume when close > open, otherwise −volume
Calculation: Cumulative volume delta = sum of bar volume delta across lower-timeframe bars in the current, still-forming higher-timeframe candle
Calculation: Flush threshold = standard deviation of cumulative volume delta values from earlier lower-timeframe bars in the current, still-forming higher-timeframe candle × sensitivity parameter; evaluate only when at least two earlier values exist
Long: bar volume delta > 0 AND abs(bar volume delta) > flush threshold
Short: bar volume delta < 0 AND abs(bar volume delta) > flush threshold