Calculation: Smoothed absorption z-score = the simple moving average, over a shorter smoothing lookback, of the z-score of volume divided by candle range; calculate the z-score using the mean and standard deviation over a longer normalization lookback.
Calculation: Close-location delta = 2 × ((close − low) / (high − low)) − 1.
Long: Smoothed absorption z-score > absorption threshold AND close-location delta > positive delta threshold
Short: Smoothed absorption z-score > absorption threshold AND close-location delta < negative delta threshold