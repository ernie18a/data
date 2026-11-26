Calculation: Averaged close = SMA(close, input averaging lookback)
Calculation: Normalized range = 100 * (Averaged close - lowest(Averaged close, extremum lookback)) / max(highest(Averaged close, extremum lookback) - lowest(Averaged close, extremum lookback), minimum price increment) - 50
Calculation: First smoothed range = moving average(Normalized range, smoothing method, smoothing length, smoothing phase)
Calculation: Second smoothed range = moving average(First smoothed range, same smoothing method, same smoothing length, same smoothing phase)
Long: First smoothed range > Second smoothed range
Short: First smoothed range <= Second smoothed range