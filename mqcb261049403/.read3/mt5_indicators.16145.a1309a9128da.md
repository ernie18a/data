Calculation: Centered range position = 100 * (SMA(close, average lookback) - Lowest(SMA(close, average lookback), extrema lookback)) / max(Highest(SMA(close, average lookback), extrema lookback) - Lowest(SMA(close, average lookback), extrema lookback), minimum price increment) - 50
Calculation: First smoothed value = selected moving average(Centered range position, smoothing method, smoothing length, smoothing phase)
Calculation: Second smoothed value = selected moving average(First smoothed value, same smoothing method, smoothing length, smoothing phase)
Long: First smoothed value > Second smoothed value AND First smoothed value > lower threshold AND Second smoothed value <= lower threshold
Short: First smoothed value <= Second smoothed value AND Second smoothed value > upper threshold AND First smoothed value <= upper threshold
Exit: long, First smoothed value > Second smoothed value AND First smoothed value > upper threshold
Exit: short, First smoothed value <= Second smoothed value AND First smoothed value < lower threshold