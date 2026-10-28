Calculation: close position = (close - low) / (high - low), or 0.5 when high = low
Calculation: volume z-score = (volume - trailing simple average of volume) / trailing standard deviation of volume; use 0 when standard deviation is 0
Calculation: delta pressure = EMA of ((2 × close position - 1) × volume / trailing simple average of volume)
Calculation: true range average = ATR
Long: volume z-score ≥ whale threshold AND close position ≥ 1 - conviction fraction OR volume z-score ≥ whale threshold AND close position ≥ 1 - conviction fraction AND delta pressure > 0 AND close ≥ EMA(close, trend length)
Short: volume z-score ≥ whale threshold AND close position ≤ conviction fraction OR volume z-score ≥ whale threshold AND close position ≤ conviction fraction AND delta pressure < 0 AND close < EMA(close, trend length)
Exit: long, high ≥ entry price + true range average at entry × stop multiple × first-target multiple OR low ≤ entry price - true range average at entry × stop multiple
Exit: short, low ≤ entry price - true range average at entry × stop multiple × first-target multiple OR high ≥ entry price + true range average at entry × stop multiple