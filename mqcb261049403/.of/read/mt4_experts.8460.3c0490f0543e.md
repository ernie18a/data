Calculation: LabTrend upper/lower channel = over its lookback, highest high minus / plus the high-low range multiplied by the channel-narrowing factor; use the indicator’s timeframe bars, including the still-forming bar.
Calculation: Smoothed Fisher = average of the current and previous Fisher values; Fisher uses the midpoint of each bar, normalized within its lookback high-low range, then recursively smoothed. Use chart-timeframe bars, including the still-forming bar.
Long: On the lower timeframe, the most recent LabTrend up arrow is newer than its most recent down arrow; use the still-forming bar.
Short: On the lower timeframe, the most recent LabTrend down arrow is newer than its most recent up arrow; use the still-forming bar.
Long: On the higher timeframe, the most recent LabTrend up arrow is newer than its most recent down arrow; use the still-forming bar.
Short: On the higher timeframe, the most recent LabTrend down arrow is newer than its most recent up arrow; use the still-forming bar.
Long: On the chart timeframe, Smoothed Fisher > 0; use the still-forming bar.
Short: On the chart timeframe, Smoothed Fisher < 0; use the still-forming bar.
Long: LabTrend trend changes from down to up when close > upper channel; use the still-forming bar.
Short: LabTrend trend changes from up to down when close < lower channel; use the still-forming bar.
Long: LabTrend trend is up AND close > upper channel; use the still-forming bar.
Short: LabTrend trend is down AND close < lower channel; use the still-forming bar.
Long: Higher-timeframe uptrend AND chart-timeframe uptrend AND Smoothed Fisher crosses from below 0 to above 0 AND +DI > -DI AND ADX > its previous value; all indicator values use their still-forming bars. AND the absolute differences between +DI and -DI, ADX and +DI, and ADX and -DI are not all below the same threshold.
Short: Higher-timeframe downtrend AND chart-timeframe downtrend AND Smoothed Fisher crosses from above 0 to below 0 AND +DI < -DI AND ADX > its previous value; all indicator values use their still-forming bars. AND the absolute differences between +DI and -DI, ADX and +DI, and ADX and -DI are not all below the same threshold.
Exit: Long, chart-timeframe downtrend OR Smoothed Fisher crosses from above 0 to below 0 OR Smoothed Fisher crosses downward through 0.25 OR the ADX/+DI/-DI flatness condition is met.
Exit: Short, chart-timeframe uptrend OR Smoothed Fisher crosses from below 0 to above 0 OR Smoothed Fisher crosses upward through -0.25 OR the ADX/+DI/-DI flatness condition is met.