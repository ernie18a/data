Calculation: Upward score = weighted sum of the conditions close > shortest moving average, and each moving average > the next longer moving average; weights increase for slower comparisons.
Calculation: Upward-score sum = rolling sum of the upward score over a shorter lookback.
Long: Upward-score sum crosses above its long-term moving average AND upward-score sum > its value at the configured earlier offset AND datetime is within the configured entry date range
Short: Upward-score sum crosses below its long-term moving average AND upward-score sum < its value at the configured earlier offset AND datetime is within the configured entry date range
Exit: long, upward-score sum crosses below its long-term moving average AND upward-score sum < its value at the configured earlier offset
Exit: short, upward-score sum crosses above its long-term moving average AND upward-score sum > its value at the configured earlier offset