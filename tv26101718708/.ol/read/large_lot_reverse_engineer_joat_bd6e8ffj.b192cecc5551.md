Calculation: Absolute close return = absolute value of (close − previous close) / absolute previous close
Calculation: Expected volume = rolling mean volume × absolute close return / rolling mean absolute close return, using the same lookback; if the rolling mean absolute close return is zero, use rolling mean volume
Calculation: Volume residual = volume − expected volume
Calculation: Residual Z-score = (volume residual − rolling mean volume residual) / rolling standard deviation of volume residual, using the same lookback; if the standard deviation is zero, use zero
Long: Residual Z-score ≥ positive block threshold AND close > previous close
Short: Residual Z-score ≥ positive block threshold AND close < previous close