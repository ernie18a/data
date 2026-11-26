Calculation: Gaussian moving-average change = Gaussian moving average(close, lookback) - Gaussian moving average(close, lookback)[1]
Long: Gaussian moving average(close, lookback) > Gaussian moving average(close, lookback)[1]
Short: Gaussian moving average(close, lookback) < Gaussian moving average(close, lookback)[1]
Long: Gaussian moving-average change > lower multiplier * standard deviation(Gaussian moving-average change, lookback) AND Gaussian moving-average change <= higher multiplier * standard deviation(Gaussian moving-average change, lookback)
Long: Gaussian moving-average change > higher multiplier * standard deviation(Gaussian moving-average change, lookback)
Short: Gaussian moving-average change < -lower multiplier * standard deviation(Gaussian moving-average change, lookback) AND Gaussian moving-average change >= -higher multiplier * standard deviation(Gaussian moving-average change, lookback)
Short: Gaussian moving-average change < -higher multiplier * standard deviation(Gaussian moving-average change, lookback)