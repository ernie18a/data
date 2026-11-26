Calculation: AMA change = AMA(close, lookback, fast smoothing lookback, slow smoothing lookback, exponent) - AMA(close, lookback, fast smoothing lookback, slow smoothing lookback, exponent)[1]
Calculation: AMA change standard deviation = population standard deviation(AMA change, lookback)
Long: AMA change > filter multiplier * AMA change standard deviation
Short: AMA change < -filter multiplier * AMA change standard deviation