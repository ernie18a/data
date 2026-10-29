Calculation: HP VWAP = volume-weighted average of the Hodrick–Prescott-filtered OHLC4 values since the start of the current user-selected timeframe interval; reset at each interval boundary. The selected timeframe may be higher, lower, or equal to the chart timeframe.
Calculation: Long stop = min(entry-bar low, prior-bar low) − ATR × stop multiplier; fix at entry.
Calculation: Long target = entry price + (entry price − long stop) × risk/reward multiplier; fix at entry.
Long: HP VWAP crosses above OHLC4 AND position is flat AND bar time is within the configured date range
Short: HP VWAP crosses below OHLC4 AND position is flat AND bar time is within the configured date range
Exit: long, low ≤ long stop OR high ≥ long target