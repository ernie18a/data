Calculation: smoothed bull-bear candle close = MA((high + low - 2 × MA(close, method 1, lookback 1, phase 1)) / 2, method 2, lookback 2, phase 2)
Calculation: smoothed bull-bear candle open = if |close[1] - open| < gap threshold × price point then smoothed bull-bear candle close[1] else MA((high + low - 2 × MA(open, method 1, lookback 1, phase 1)) / 2, method 2, lookback 2, phase 2)
Long: smoothed bull-bear candle open < smoothed bull-bear candle close
Short: smoothed bull-bear candle open > smoothed bull-bear candle close