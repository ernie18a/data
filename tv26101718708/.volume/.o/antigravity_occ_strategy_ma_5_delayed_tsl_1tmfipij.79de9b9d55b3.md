Calculation: Close MA = selected moving average of close shifted by the configured delay, on the alternate higher-timeframe bar still forming (or chart timeframe when alternate resolution is disabled)
Calculation: Open MA = selected moving average of open shifted by the same delay and using the same MA type and lookback as Close MA, on the same timeframe
Calculation: Adaptive ADX threshold = 50th percentile of ADX over the configured lookback; use the configured manual threshold when adaptive mode is disabled
Calculation: Long stop = entry price × (1 − fixed stop %) until high has exceeded entry price × (1 + activation %); afterward, max(high × (1 − trailing %), previous long stop)
Calculation: Short stop = entry price × (1 + fixed stop %) until low has fallen below entry price × (1 − activation %); afterward, min(low × (1 + trailing %), previous short stop)
Long: Close MA > Open MA AND previous Close MA ≤ previous Open MA AND (ADX filter disabled OR ADX > configured threshold)
Short: Close MA < Open MA AND previous Close MA ≥ previous Open MA AND (ADX filter disabled OR ADX > configured threshold)
Exit: long, low ≤ long stop OR high ≥ entry price × (1 + take-profit %)
Exit: short, high ≥ short stop OR low ≤ entry price × (1 − take-profit %)