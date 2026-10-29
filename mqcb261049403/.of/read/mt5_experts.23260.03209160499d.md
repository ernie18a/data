Calculation: SR rate = 200 × (S(weighted close) − minimum of S(low) over the lookback) / (maximum of S(high) − minimum of S(low) over the lookback) − 100; use 0 if the denominator is 0. S(price) is the normalized weighted average of the current and four preceding bars, with weights exp(−i²/4) for i = 0…4, where i counts bars back. Use bars from a lower timeframe; evaluate the current and preceding SR rate on completed bars.
Long: current SR rate > upper threshold AND preceding SR rate ≤ upper threshold
Short: current SR rate < lower threshold AND preceding SR rate ≥ lower threshold
Exit: long, current SR rate < lower threshold AND preceding SR rate ≥ lower threshold
Exit: short, current SR rate > upper threshold AND preceding SR rate ≤ upper threshold