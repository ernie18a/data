Calculation: Long score = 3×(close > long-term EMA(close)) + 3×(volume > SMA(volume, lookback)) + 2×(RSI(close) < upper threshold) + 2×(close > open)
Calculation: Short score = 3×(close < long-term EMA(close)) + 3×(volume > SMA(volume, lookback)) + 2×(RSI(close) > lower threshold) + 2×(close < open)
Calculation: ATR = average true range
Long: Long score >= minimum score AND position size <= 0; enter on a stop at the armed bar's high + ATR × multiplier
Short: Short score >= minimum score AND position size >= 0; enter on a stop at the armed bar's low − ATR × multiplier