Calculation: M = Moving Average(applied price, lookback, smoothing method, shift, current chart bar)
Calculation: C = Chaikin Oscillator(tick volume, shorter lookback, longer lookback, smoothing method, last completed chart bar)
Long: close[1] > open[1] AND low[1] < M AND ((no position is open AND C < entry threshold) OR (short position is open AND C < hedge threshold))
Short: close[1] < open[1] AND high[1] > M AND ((no position is open AND C > entry threshold) OR (long position is open AND C > hedge threshold))