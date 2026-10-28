Calculation: Upper Bollinger Band = basis + standard-deviation multiplier × source standard deviation over the Bollinger lookback
Calculation: Lower Bollinger Band = basis − standard-deviation multiplier × source standard deviation over the Bollinger lookback
Long: close crosses above lower Bollinger Band AND not already long AND datetime is within the configured date range AND (filters disabled OR (volume exceeds its moving average by the configured long threshold AND close > trend SMA))
Short: close crosses below upper Bollinger Band AND not already short AND datetime is within the configured date range AND (filters disabled OR (volume exceeds its moving average by the configured short threshold AND close < trend SMA AND RSI < configured ceiling))
Exit: long, close crosses above upper Bollinger Band AND datetime is within the configured date range
Exit: short, close crosses below lower Bollinger Band AND datetime is within the configured date range