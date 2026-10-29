Calculation: Open MA = selected moving average of open price; uses the same MA type and lookback as Close MA. When alternate resolution is enabled, calculate on the higher timeframe using its still-forming bar, with the configured bar delay.
Calculation: Close MA = selected moving average of close price; uses the same MA type and lookback as Open MA. When alternate resolution is enabled, calculate on the higher timeframe using its still-forming bar, with the configured bar delay.
Long: Close MA > Open MA AND previous Close MA <= previous Open MA
Short: Close MA < Open MA AND previous Close MA >= previous Open MA
Exit: long, Close MA < Open MA AND previous Close MA >= previous Open MA OR low <= entry price minus configured stop distance OR high >= entry price plus configured target distance
Exit: short, Close MA > Open MA AND previous Close MA <= previous Open MA OR high >= entry price plus configured stop distance OR low <= entry price minus configured target distance