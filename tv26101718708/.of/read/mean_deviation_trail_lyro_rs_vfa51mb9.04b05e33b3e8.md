Calculation: Mean absolute deviation = the average over a lookback of the absolute differences between each historical source value and the current bar's EMA of the source.
Calculation: Smoothed deviation = a selectable moving average of (source − EMA of source) / mean absolute deviation; use zero for the unsmoothed deviation when mean absolute deviation is not positive. The source is a selectable price series.
Long: Smoothed deviation > 0.
Short: Smoothed deviation <= 0.
Long: Smoothed deviation > 0 AND previous smoothed deviation <= 0.
Short: Smoothed deviation <= 0 AND previous smoothed deviation > 0.