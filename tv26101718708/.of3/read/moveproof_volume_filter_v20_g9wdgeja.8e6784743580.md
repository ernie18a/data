Calculation: Capped volume = if adaptive averaging is enabled, min(volume, (the previous bar's EMA of volume over the volume-average lookback if defined, otherwise volume) × the outlier cap multiplier), else volume
Calculation: Relative volume = volume / the selected SMA, EMA, or RMA of capped volume over the volume-average lookback, when that average is positive; otherwise undefined
Calculation: Bullish close strength = if high > low, (close - low) / (high - low), else 0.5
Calculation: Bearish close strength = if high > low, (high - close) / (high - low), else 0.5
Long: close > highest(high[1], breakout lookback) AND close > open AND bullish close strength >= close-strength requirement AND relative volume >= strong-volume multiplier
Short: close < lowest(low[1], breakout lookback) AND close < open AND bearish close strength >= close-strength requirement AND relative volume >= strong-volume multiplier
Long: low < lowest(low[1], breakout lookback) AND (relative volume <= weak-volume multiplier OR bearish close strength < close-strength requirement)
Short: high > highest(high[1], breakout lookback) AND (relative volume <= weak-volume multiplier OR bullish close strength < close-strength requirement)