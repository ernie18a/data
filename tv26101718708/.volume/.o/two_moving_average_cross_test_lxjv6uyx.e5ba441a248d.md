Calculation: Fast MA = selected moving average of its source on the configured timeframe, using the shorter lookback and completed bars
Calculation: Slow MA = selected moving average of its source on the configured timeframe, using the longer lookback and completed bars
Calculation: Long stop = low of the entry bar × (1 − configured stop percentage / 100)
Long: Fast MA crosses above Slow MA
Long: Fast MA crosses above Slow MA AND RSI of close is above the configured minimum AND position is flat AND the strategy start-date filter passes
Short: Slow MA crosses above Fast MA
Exit: long, low is at or below the Long stop
Exit: long, (Slow MA crosses above Fast MA AND RSI of configured source is below the configured minimum) OR RSI of configured source is above the configured maximum