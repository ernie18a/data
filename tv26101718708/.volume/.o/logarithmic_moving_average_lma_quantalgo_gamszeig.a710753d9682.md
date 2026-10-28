Calculation: Logarithmic moving average = weighted average of current and prior closes, with weight for each bar proportional to 1 / log(bar age + steepness)²; use one lookback length and steepness parameter.
Calculation: Trend quality = squared correlation between bar age and log close over the same lookback as the logarithmic moving average, clamped to [0, 1].
Calculation: Log-return momentum = sum of log(close / prior close) over the same lookback, annualized.
Calculation: Smoothed signal = smooth the logarithmic moving average’s percentage change over a shorter lookback, multiplied by (0.5 + 0.5 × trend quality); when log-return momentum has the same sign as this signal and exceeds a minimum magnitude, multiply the signal by a confirmation factor.
Long: Smoothed signal > 0 OR crosses above 0 OR crosses above the long threshold
Short: Smoothed signal < 0 OR crosses below 0 OR crosses below the short threshold
Exit: Long, crosses below the long threshold
Exit: Short, crosses above the short threshold