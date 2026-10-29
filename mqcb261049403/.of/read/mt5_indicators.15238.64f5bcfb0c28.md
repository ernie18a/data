Calculation: XCCX = 100 × smoothed(price − smoothed(price)) / smoothed(abs(price − smoothed(price))); use the selected price and smoothing method, with the price smoother and deviation smoother using their respective lookbacks
Calculation: XCCX change = current XCCX − previous XCCX
Calculation: Change standard deviation = population standard deviation of XCCX changes over the lookback
Calculation: Change threshold = selected coefficient × change standard deviation; round both the current XCCX change and threshold to instrument digits + 2 decimal places
Long: XCCX > previous XCCX OR rounded XCCX change > rounded change threshold
Short: XCCX < previous XCCX OR rounded XCCX change < −rounded change threshold