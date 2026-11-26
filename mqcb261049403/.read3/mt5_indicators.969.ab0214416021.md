Calculation: tick size = if (high - low) / volume = 0 then 1 else (high - low) / volume
Calculation: swing = ((high - low) + abs(open - close)) / (2 * tick size)
Calculation: bull score = moving average(if open > close then (open - close) / tick size + swing else swing, smoothing method, lookback, phase)
Calculation: bear score = moving average(if open < close then (close - open) / tick size + swing else swing, smoothing method, lookback, phase)
Long: bear score > bull score
Short: bull score > bear score