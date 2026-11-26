Calculation: zero-lag moving-average change = ZeroLagMA(close, moving-average lookback) - ZeroLagMA(close, moving-average lookback)[1]
Calculation: change standard deviation = StandardDeviation(zero-lag moving-average change, deviation lookback)
Long: zero-lag moving-average change > smaller multiplier × change standard deviation AND zero-lag moving-average change <= larger multiplier × change standard deviation
Long: zero-lag moving-average change > larger multiplier × change standard deviation
Short: zero-lag moving-average change < -smaller multiplier × change standard deviation AND zero-lag moving-average change >= -larger multiplier × change standard deviation
Short: zero-lag moving-average change < -larger multiplier × change standard deviation