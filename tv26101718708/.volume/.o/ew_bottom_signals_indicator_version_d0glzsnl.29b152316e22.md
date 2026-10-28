Calculation: Short-term SMA = SMA(close, shorter lookback)
Calculation: Long-term SMA = SMA(close, longer lookback)
Calculation: Volume spike = volume > SMA(volume, lookback) × multiplier
Calculation: Capitulation candle = open > close AND (high − low − abs(close − open)) > abs(close − open) AND volume spike
Calculation: Active Wave C = a confirmed swing high, then a confirmed swing low, then a confirmed swing high; remains active until the next confirmed swing low. A confirmed swing high is high[depth] = highest(high, 2 × depth + 1); a confirmed swing low is low[depth] = lowest(low, 2 × depth + 1).
Long: Active Wave C AND close < long-term SMA AND capitulation candle OR previous bar's first-buy condition AND close crosses above short-term SMA OR previous bar's second-buy condition AND short-term SMA crosses above long-term SMA
Exit: Long, short-term SMA crosses below long-term SMA