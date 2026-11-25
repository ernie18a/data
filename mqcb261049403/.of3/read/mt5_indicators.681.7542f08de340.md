Calculation: K = threshold-base parameter - risk parameter
Calculation: Trend = up if Williams %R(lookback) > -K, else down if Williams %R(lookback) < -100 + K, otherwise prior Trend; initially down
Long: Trend[1] = down AND Trend = up
Short: Trend[1] = up AND Trend = down