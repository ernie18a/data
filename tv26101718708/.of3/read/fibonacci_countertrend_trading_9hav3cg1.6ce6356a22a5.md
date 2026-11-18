Calculation: upper Fibonacci level = VWMA(source, lookback) + upper fraction × multiplier × standard deviation(source, lookback)
Calculation: lower Fibonacci level = VWMA(source, lookback) − lower fraction × multiplier × standard deviation(source, lookback)
Long: source crosses below lower Fibonacci level
Short: source crosses above upper Fibonacci level
Exit: long, base-line exit parameter is enabled AND source crosses VWMA(source, lookback) OR base-line exit parameter is disabled AND low <= lower Fibonacci level
Exit: short, base-line exit parameter is enabled AND source crosses VWMA(source, lookback) OR base-line exit parameter is disabled AND high >= upper Fibonacci level