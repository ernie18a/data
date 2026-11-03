Calculation: Pulse = RSI recentered as (RSI − 50) / 50, blended with clipped MACD histogram normalized by twice its rolling standard deviation; use the configured RSI, MACD, normalization lookbacks, and RSI weight.
Calculation: Pulse slope = current pulse − pulse from the configured slope lookback.
Calculation: Long stop = signal-bar low − ATR × stop multiplier; long target = entry price + abs(entry price − long stop) × risk:reward.
Calculation: Short stop = signal-bar high + ATR × stop multiplier; short target = entry price − abs(short stop − entry price) × risk:reward.
Long: pulse > positive trigger AND pulse state was not bullish AND (slope filter disabled OR pulse slope > 0) AND (candle confirmation disabled OR close > open) AND signal bar is confirmed AND minimum bars since prior signal have elapsed.
Short: pulse < negative trigger AND pulse state was not bearish AND (slope filter disabled OR pulse slope < 0) AND (candle confirmation disabled OR close < open) AND signal bar is confirmed AND minimum bars since prior signal have elapsed.
Exit: long, high ≥ long target OR low ≤ long stop OR an eligible short signal occurs.
Exit: short, low ≤ short target OR high ≥ short stop OR an eligible long signal occurs.