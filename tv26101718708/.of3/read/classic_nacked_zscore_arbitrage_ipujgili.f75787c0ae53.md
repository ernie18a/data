Long: ZScore(close(A, T1, forming) - close(B, T1, forming), lookback) > threshold, calculated on chart bars using values from the forming T1 bar
Short: ZScore(close(A, T1, forming) - close(B, T1, forming), lookback) < -threshold, calculated on chart bars using values from the forming T1 bar
Calculation: price spread = closing price of Asset A on T1 - closing price of Asset B on T1
Long: Z-score of price spread over lookback parameter > threshold parameter
Short: Z-score of price spread over lookback parameter < -threshold parameter