Calculation: Higher-timeframe data = bars aggregated to a higher timeframe than the chart, including the bar still forming; calculations use that bar and preceding completed higher-timeframe bars.
Calculation: Relative Trend Index = 100 times (close minus the lower percentile of close minus the standard deviation of close over a short lookback) divided by (the upper percentile of close plus that standard deviation minus the lower percentile of close minus that standard deviation); percentiles use nearest rank over a longer lookback.
Calculation: Absolute Strength Index = 2 times (the return from close a lookback ago to current close minus the lower percentile of preceding one-bar returns) divided by (the upper percentile of those returns minus the lower percentile) minus 1; use the lookback number of preceding one-bar returns, nearest-rank percentiles, and zero if the denominator is zero or the current return is unavailable.
Calculation: Range center = weighted mean of higher-timeframe closes over a lookback, weighting each close by the absolute change from the preceding close divided by the preceding close; omit bars without a valid preceding close.
Calculation: Swing direction = on each higher-timeframe bar, record the most recent bar whose high equals or exceeds every high in its swing lookback and the most recent bar whose low equals or falls below every low in that lookback; direction is up when the recorded high is more recent than the recorded low, and down otherwise. A direction change confirms the most recently recorded low as a swing low when direction changes to up, or the most recently recorded high as a swing high when direction changes to down.
Long: Higher-timeframe MACD histogram > 0.
Short: Higher-timeframe MACD histogram < 0.
Long: Higher-timeframe RSI > its overbought threshold.
Short: Higher-timeframe RSI < its oversold threshold.
Long: Higher-timeframe Relative Trend Index > its overbought threshold.
Short: Higher-timeframe Relative Trend Index < its oversold threshold.
Long: Higher-timeframe Absolute Strength Index > its overbought threshold.
Short: Higher-timeframe Absolute Strength Index < its oversold threshold.
Long: Higher-timeframe close > Range center AND the higher-timeframe ATR used for normalization is available and nonzero.
Short: Higher-timeframe close < Range center AND the higher-timeframe ATR used for normalization is available and nonzero.
Long: Swing direction = up.
Short: Swing direction = down.
Long: A higher-timeframe swing high is confirmed AND its price > the preceding confirmed swing high OR a higher-timeframe swing low is confirmed AND its price > the preceding confirmed swing low.
Short: A higher-timeframe swing high is confirmed AND its price < the preceding confirmed swing high OR a higher-timeframe swing low is confirmed AND its price < the preceding confirmed swing low.