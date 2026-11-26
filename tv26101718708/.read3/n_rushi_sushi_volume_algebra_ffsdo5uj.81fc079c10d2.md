Calculation: Volume ratio = if volume[n] != 0 then volume / volume[n] else 1
Calculation: Price change percentage = if close[n] != 0 then 100 * (close - close[n]) / close[n] else 0
Calculation: Score = max(0, volume-change weight * 100 * (Volume ratio - 1) + price-change weight * abs(Price change percentage) + volume-ratio weight * min(Volume ratio, ratio cap))
Long: Volume ratio > volume-increase threshold AND Price change percentage > 0 AND Score >= minimum score
Short: Volume ratio > volume-increase threshold AND Price change percentage < 0 AND Score >= minimum score
Exit: long, low <= entry price - ATR(lookback, entry bar) * stop multiplier
Exit: short, high >= entry price + ATR(lookback, entry bar) * stop multiplier