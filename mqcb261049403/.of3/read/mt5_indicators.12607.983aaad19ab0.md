Calculation: Processed price = SMA(close, processing lookback) on T1 bars; chart bars use the selected T1 bar, which is still forming when the current bar is selected
Calculation: Centered range position = 100 * (Processed price - Lowest(Processed price, extrema lookback)) / max(Highest(Processed price, extrema lookback) - Lowest(Processed price, extrema lookback), minimum price increment) - 50
Calculation: First smoother = configured smoothing method(Centered range position, smoothing lookback, smoothing phase)
Calculation: Second smoother = configured smoothing method(First smoother, same smoothing parameters)
Long: First smoother > Second smoother AND First smoother[1] <= Second smoother[1]
Short: First smoother <= Second smoother AND First smoother[1] > Second smoother[1]