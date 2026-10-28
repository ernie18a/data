Calculation: Smoothed absorption z-score = SMA of (current volume divided by current high-low, minus its longer-lookback SMA, divided by its longer-lookback standard deviation), over a shorter lookback
Calculation: Incoming selling = current close < its short-lookback SMA AND current close < close from the trend lookback bars ago
Calculation: Incoming buying = current close > its short-lookback SMA AND current close > close from the trend lookback bars ago
Long: Smoothed absorption z-score > absorption threshold AND Incoming selling
Short: Smoothed absorption z-score > absorption threshold AND Incoming buying