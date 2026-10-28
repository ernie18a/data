Calculation: Close MA = selected moving average of close, using the same selected method and lookback as Open MA; calculated on the chart timeframe or configured alternate timeframe, using its current forming bar.
Calculation: Open MA = selected moving average of open; calculated on the chart timeframe or configured alternate timeframe, using its current forming bar.
Long: Close MA > Open MA AND previous Close MA <= previous Open MA
Short: Close MA < Open MA AND previous Close MA >= previous Open MA
Exit: Long, Close MA < Open MA AND previous Close MA >= previous Open MA (when configured for long-only trading)
Exit: Short, Close MA > Open MA AND previous Close MA <= previous Open MA (when configured for short-only trading)
Exit: Long, low <= entry price - configured stop distance OR high >= entry price + configured target distance (when the respective stop or target is enabled)
Exit: Short, high >= entry price + configured stop distance OR low <= entry price - configured target distance (when the respective stop or target is enabled)