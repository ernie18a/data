Calculation: Estimated volume delta = volume × ((close − low) − (high − close)) / (high − low), or the sum of this estimate over lower-timeframe bars within the chart bar when intrabar analysis is enabled; use 0 when high = low.
Calculation: Cumulative volume delta = rolling sum of estimated volume delta over a lookback.
Calculation: Volume outlier = a volume bar flagged by the selected statistical outlier test; when combined tests are selected, flag it when at least two tests agree.
Calculation: Cluster breakout = volume cluster density was above its threshold on the previous bar, is not above it now, and current volume exceeds 1.3 times the rolling mean volume.
Calculation: Volume divergence = price makes a new lookback low while cumulative volume delta makes a higher lookback low, or price makes a new lookback high while cumulative volume delta makes a lower lookback high.
Long: Price breaks above a range or pattern AND volume is above its moving average by the selected relative-volume threshold AND volume is not an outlier AND estimated volume delta > 0
Short: Price breaks below a range or pattern AND volume is above its moving average by the selected relative-volume threshold AND volume is not an outlier AND estimated volume delta < 0
Long: A volume outlier bar is followed by price breaking above that bar's high
Short: A volume outlier bar is followed by price breaking below that bar's low
Long: Bullish volume divergence AND (close > open OR volume outlier AND estimated volume delta > 0)
Short: Bearish volume divergence AND (close < open OR volume outlier AND estimated volume delta < 0)
Long: Cluster breakout AND estimated volume delta > 0
Short: Cluster breakout AND estimated volume delta < 0
Exit: long, low < the recent low used for bullish volume divergence
Exit: short, high > the recent high used for bearish volume divergence