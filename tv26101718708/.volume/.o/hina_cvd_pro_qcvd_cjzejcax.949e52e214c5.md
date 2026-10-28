Calculation: True-range proxy delta = for close ≥ open, volume × ((close − low) − (high − close)) / true range; otherwise, volume × ((high − open) − (close − low)) / true range; use 1 when true range is 0
Calculation: Delta z-score = (delta − rolling mean of delta) / rolling standard deviation of delta, using the same lookback for both
Calculation: Close position = 0.5 if high = low; otherwise, (close − low) / (high − low)
Calculation: Short-term delta EMA = exponential moving average of delta
Long: Delta z-score < −anomaly threshold AND close position > 0.70
Short: Delta z-score > anomaly threshold AND close position < 0.30
Exit: long, close < low of entry-signal bar OR (more than two bars since entry AND short-term delta EMA < 0)
Exit: short, close > high of entry-signal bar OR (more than two bars since entry AND short-term delta EMA > 0)