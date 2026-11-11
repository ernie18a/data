Calculation: Zero-lag moving average = 2 × moving average of close − moving average of that moving average, using the same length and either EMA or SMA for both.
Calculation: Zero-lag MACD = shorter-length zero-lag moving average − longer-length zero-lag moving average.
Calculation: Signal = either SMA of zero-lag MACD or 2 × EMA of zero-lag MACD − EMA of that EMA, with both EMAs using the same signal length.
Calculation: Histogram = zero-lag MACD − signal.
Calculation: Ease of movement = SMA of (positive divisor × change in (high + low) / 2 × (high − low) / volume).
Long: Zero-lag MACD crosses above signal.
Short: Zero-lag MACD crosses below signal.
Long: Zero-lag MACD crosses above signal AND zero-lag MACD < histogram AND close > Kijun-sen AND ease of movement > 0.
Short: Zero-lag MACD crosses below signal AND zero-lag MACD > histogram AND close < Kijun-sen AND ease of movement < 0.
Exit: long, low <= entry price − previous bar ATR × stop multiplier OR high >= entry price + previous bar ATR × stop multiplier × risk-reward ratio.
Exit: short, high >= entry price + previous bar ATR × stop multiplier OR low <= entry price − previous bar ATR × stop multiplier × risk-reward ratio.