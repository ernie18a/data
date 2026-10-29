Calculation: Composite = [7 × (100 × (smoothed (close − low) / (high − low) − 0.5)) + 9 × (RSI of close − 50) + CCI of median price] / 3; calculate on the chart timeframe or selected higher timeframe, using the bar still forming
Calculation: Upper line = follow Composite from the previous bar’s Upper line only when their difference exceeds a threshold; then set it to Composite minus the threshold if Composite is higher, or Composite plus the threshold if lower; otherwise retain the previous Upper line
Calculation: Lower line = the average of the smoothed rolling highest and smoothed rolling lowest Upper line values, using the same lookback for both extrema and the same smoothing method and length for both
Long: Upper line > Lower line
Short: Upper line < Lower line