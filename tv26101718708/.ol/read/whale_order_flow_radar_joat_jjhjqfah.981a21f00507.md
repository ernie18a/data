Calculation: Volume z-score = (current bar volume − rolling mean volume) / rolling standard deviation of volume
Calculation: Close position in bar range = (close − low) / (high − low), or 0.5 when high = low
Calculation: Pressure = EMA of [current bar volume × (2 × close position in bar range − 1) / rolling mean volume]
Long: Volume z-score ≥ whale threshold AND close position in bar range ≥ 1 − conviction fraction
Long: Volume z-score ≥ whale threshold AND close position in bar range ≥ 1 − conviction fraction AND Pressure > 0 AND (trend filter disabled OR close ≥ EMA(close)) AND bars since previous signal ≥ minimum spacing
Short: Volume z-score ≥ whale threshold AND close position in bar range ≤ conviction fraction
Short: Volume z-score ≥ whale threshold AND close position in bar range ≤ conviction fraction AND Pressure < 0 AND (trend filter disabled OR close < EMA(close)) AND bars since previous signal ≥ minimum spacing