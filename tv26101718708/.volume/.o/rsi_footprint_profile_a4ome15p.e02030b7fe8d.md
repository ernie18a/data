Calculation: Session price rows = Divide the high-to-low range of each fixed-length chart-bar box into equal-width rows; assign each completed bar’s volume and RSI equally across every row touched by that bar’s low-to-high range.
Calculation: Row RSI = Sum of each bar’s RSI multiplied by its volume allocated to the row, divided by the row’s total allocated volume.
Long: Any session price row’s RSI <= oversold threshold
Short: Any session price row’s RSI >= overbought threshold