Calculation: Smoothed open, high, low, and close = for each field, the weighted average of its values over the current and preceding bars; for age fraction q from 0 (current) to 1 (oldest), weight = [Shift1 + q^rank1 × (1−Shift1)] × [Shift2 + (1−q)^rank2 × (1−Shift2)] × [Shift3 + |2q−1|^rank3 × (1−Shift3)], normalized so weights sum to 1
Calculation: Smoothed candle open = smoothed open, except use the previous bar’s smoothed close when the current bar’s |open−close| is no greater than the gap threshold
Calculation: Smoothed candle direction = compare smoothed candle open with smoothed close
Calculation: Smoothed range midpoint = (smoothed high + smoothed low) / 2
Calculation: Midpoint increment = current smoothed range midpoint − previous smoothed range midpoint
Calculation: Increment standard deviation = population standard deviation of the current and preceding midpoint increments over a lookback period
Calculation: Strong-move thresholds = the increment standard deviation multiplied by a lower and a higher coefficient, with the higher coefficient greater than the lower coefficient
Long: Smoothed candle direction is bullish OR midpoint increment > lower strong-move threshold
Short: Smoothed candle direction is bearish OR midpoint increment < −lower strong-move threshold