Calculation: Trend = Smooth(selected OHLC price vote series, smoothing method 2, lookback 2, smoothing parameter 2), where the vote series is 100 × (2 × count of i for which close > Smooth(selected OHLC price, smoothing method 1, starting lookback + i × lookback increment, smoothing parameter 1) ÷ number of lookbacks − 1), for i from 0 to number of lookbacks − 1; calculated on T1 bars. Trend[n] is its value n T1 bars back; n = 0 is the forming bar, n > 0 are completed bars.
Long: Trend > 0
Short: Trend < 0
Long: Trend[n] > upper threshold AND Trend[n+1] <= upper threshold
Short: Trend[n] < lower threshold AND Trend[n+1] >= lower threshold
Long: Trend[n+2] > Trend[n+1] AND Trend[n] > Trend[n+1]
Short: Trend[n+2] < Trend[n+1] AND Trend[n] < Trend[n+1]