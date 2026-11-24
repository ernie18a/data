Calculation: Normalized range width = (highest(high, shorter lookback) - lowest(low, shorter lookback)) / close
Calculation: Range height = highest(high, qualifying quiet range) - lowest(low, qualifying quiet range)
Long: On a closed bar, normalized range width < tightness threshold × SMA(normalized range width, longer comparison lookback) for a consecutive run lasting at least the minimum range duration, then close crosses above the qualifying range high within the breakout wait period
Short: On a closed bar, normalized range width < tightness threshold × SMA(normalized range width, longer comparison lookback) for a consecutive run lasting at least the minimum range duration, then close crosses below the qualifying range low within the breakout wait period
Exit: long, after the breakout bar and no later than target expiry, high >= qualifying range high + target multiple × range height
Exit: short, after the breakout bar and no later than target expiry, low <= qualifying range low - target multiple × range height
Exit: long, while the target is live and failure invalidation is enabled, close < qualifying range low
Exit: short, while the target is live and failure invalidation is enabled, close > qualifying range high