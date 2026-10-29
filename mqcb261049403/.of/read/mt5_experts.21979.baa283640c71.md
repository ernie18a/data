Calculation: Volume-weighted RSI histogram = smooth (RSI of the selected bar price minus 50) multiplied by bar volume, using the selected moving-average method and smoothing lookback. For the trading decisions, calculate it on a higher timeframe using the last completed bar; for the indicator's own markings, calculate it on the chart timeframe using the bar still forming.
Calculation: Histogram direction = up when the histogram is greater than its previous bar, down when it is less, and otherwise the previous direction.
Long: Histogram direction is up AND previous histogram direction is down.
Short: Histogram direction is down AND previous histogram direction is up.
Exit: short, histogram direction is up OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.
Exit: long, histogram direction is down OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.