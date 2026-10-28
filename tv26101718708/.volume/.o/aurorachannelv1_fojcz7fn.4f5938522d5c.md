Calculation: Adaptive moving average = select the lowest-scoring SMA, EMA, RMA, WMA, or VWMA of close, scoring each as the same-lookback SMA of squared error from close plus a jitter penalty times the same-lookback SMA of squared changes in that candidate
Long: close > adaptive moving average
Short: close <= adaptive moving average