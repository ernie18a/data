Calculation: Signed volume = volume when close > previous close, otherwise −volume
Calculation: Volume z-score = short-term simple moving average of signed volume divided by its longer-term standard deviation
Calculation: Predicted price = (close + standard deviation of close) / (1 + (standard deviation of close / close) × exp(−volume z-score)); use a shorter lookback than the longer-term volume standard deviation
Long: Predicted price > close × 1.005
Exit: Long, Predicted price < close × 0.995