Calculation: Volume-weighted RSI = RSI of close gains and losses multiplied by relative volume (bar volume / its moving average), using Wilder smoothing.
Calculation: Signal line = EMA of the volume-weighted RSI.
Long: Volume-weighted RSI crosses above the oversold level (current > level AND previous <= level)
Long: At a confirmed volume-weighted RSI pivot low (same configurable lookback on each side), its value is higher and the low is lower than at the previous confirmed volume-weighted RSI pivot low.
Long: Volume-weighted RSI crosses above its signal line (current RSI > current signal line AND previous RSI <= previous signal line)
Short: Volume-weighted RSI crosses below the overbought level (current < level AND previous >= level)
Short: At a confirmed volume-weighted RSI pivot high (same configurable lookback on each side), its value is lower and the high is higher than at the previous confirmed volume-weighted RSI pivot high.
Short: Volume-weighted RSI crosses below its signal line (current RSI < current signal line AND previous RSI >= previous signal line)