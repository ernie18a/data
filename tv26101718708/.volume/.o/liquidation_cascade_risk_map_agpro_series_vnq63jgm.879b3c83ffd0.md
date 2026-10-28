Calculation: Participation pressure = volume (the available volume-proxy data); usable when volume > 0
Calculation: Fast and slow price averages = EMAs of close, with the fast length shorter than the slow length
Calculation: Volatility shock = ATR divided by close, normalized by its longer-lookback average
Calculation: Range shock = (high − low) divided by close, normalized by its longer-lookback average
Calculation: Body shock = absolute(close − open) divided by close, normalized by its longer-lookback average
Calculation: Pressure change = percentage change in participation pressure over the fast pressure lookback
Calculation: Pressure velocity = short EMA of the change in pressure change
Calculation: Slow-average distance = (close − slow price average) divided by ATR
Calculation: Upper-wick share = (high − max(open, close)) divided by (high − low); lower-wick share = (min(open, close) − low) divided by (high − low)
Calculation: Cascade score = weighted, normalized, 0–100 blend of volatility shock, range shock, body shock, absolute pressure change, absolute pressure velocity, and absolute slow-average distance
Calculation: Cooling score = normalized, 0–100 blend of falling volatility shock and negative pressure velocity
Calculation: Downside stress = (close < open AND close < fast price average AND close < slow price average) OR (upper-wick share exceeds its threshold AND close < fast price average)
Calculation: Upside stress = (close > open AND close > fast price average AND close > slow price average) OR (lower-wick share exceeds its threshold AND close > fast price average)
Calculation: Long raw risk = usable participation pressure AND cascade score at or above its threshold AND downside stress AND slow-average distance below its negative distance threshold
Calculation: Short raw risk = usable participation pressure AND cascade score at or above its threshold AND upside stress AND slow-average distance above its positive distance threshold
Calculation: Long persistence = percentage of recent persistence bars with long raw risk; short persistence = percentage of recent persistence bars with short raw risk
Long: usable participation pressure AND cascade score ≥ cascade threshold AND downside stress AND slow-average distance < −distance threshold AND long persistence ≥ persistence threshold
Short: usable participation pressure AND cascade score ≥ cascade threshold AND upside stress AND slow-average distance > distance threshold AND short persistence ≥ persistence threshold