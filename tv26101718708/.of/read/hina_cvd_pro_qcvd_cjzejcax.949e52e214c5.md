Calculation: Estimated delta = estimated buy volume − estimated sell volume; if close ≥ open, estimated buy volume = volume × (close − low) / true range and estimated sell volume = volume × (high − close) / true range; otherwise, estimated buy volume = volume × (high − open) / true range and estimated sell volume = volume × (close − low) / true range. Use 1 when true range is 0.
Calculation: Delta Z-score = (estimated delta − its rolling mean) / its rolling standard deviation, using the same lookback for both.
Calculation: Close location within bar = (close − low) / (high − low); use 0.5 when high = low.
Long: Delta Z-score < negative anomaly threshold AND close location within bar > upper close-location threshold AND current bar is complete.
Short: Delta Z-score > positive anomaly threshold AND close location within bar < lower close-location threshold AND current bar is complete.
Exit: long, close < low of the long-entry signal bar OR, after the minimum holding period, short-term EMA of estimated delta < 0.
Exit: short, close > high of the short-entry signal bar OR, after the minimum holding period, short-term EMA of estimated delta > 0.