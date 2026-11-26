Calculation: m = MovingAverage((high + low + close) / 3, lookback, T1, last completed bar)
Calculation: smoothed ATR = Smooth(ATR(ATR lookback, T1, last completed bar), ATR smoothing method, ATR smoothing length, ATR phase)
Calculation: smoothed standard deviation = Smooth(StandardDeviation(close, standard-deviation lookback, T1, last completed bar), standard-deviation smoothing method, standard-deviation smoothing length, standard-deviation phase)
Calculation: Flat-Trend state = 2 if smoothed ATR > smoothed ATR[1] AND smoothed standard deviation > smoothed standard deviation[1]; 1 if both are lower than their [1] values; otherwise 0
Long: m > m[1] AND m[1] < m[2]
Long: m > m[1] AND m[1] < m[2] AND Flat-Trend state >= volatility-state threshold
Short: m < m[1] AND m[1] > m[2]
Short: m < m[1] AND m[1] > m[2] AND Flat-Trend state >= volatility-state threshold
Exit: long, m < m[1] OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, m > m[1] OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance