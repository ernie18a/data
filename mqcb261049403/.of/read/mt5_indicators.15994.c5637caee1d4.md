Calculation: Selected price = the configured price derived from bar OHLC (such as close, open, high, low, median, typical, or weighted close).
Calculation: Smoothed price = moving average of selected price using the configured averaging method and lookback.
Calculation: CAi line = previous line + k × (smoothed price − previous line), where k = 0 if (previous line − smoothed price)² is less than the variance of selected price around smoothed price over the same lookback, or is zero; otherwise k = 1 − variance / (previous line − smoothed price)². Initialize the previous line to smoothed price when unavailable.
Calculation: Line increment = current CAi line − previous CAi line.
Calculation: Increment standard deviation = population standard deviation of line increments over a lookback.
Calculation: Lower threshold = lower positive multiplier × increment standard deviation; upper threshold = higher positive multiplier × increment standard deviation.
Long: Line increment > lower threshold
Short: Line increment < −lower threshold