Calculation: Cumulative delta = sum over a lookback of volume × sign(close − prior bar close)
Calculation: Delta z-score = cumulative delta / (standard deviation of signed volume over the same lookback × square root of the lookback)
Calculation: Price z-score = (close − average close over the same lookback) / standard deviation of close over the same lookback
Calculation: Divergence = price z-score − delta z-score
Calculation: EMA = exponential moving average of close
Long: divergence ≤ −threshold AND close crosses above EMA AND position is flat or short AND cooldown bars have elapsed since the last signal AND bar is confirmed
Short: divergence ≥ threshold AND close crosses below EMA AND position is flat or long AND cooldown bars have elapsed since the last signal AND bar is confirmed