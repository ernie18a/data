Calculation: EMA envelope state = 2 if high > EMA(high) and low > EMA(low) and low > EMA(high); 1 if high > EMA(high) and low > EMA(low); -2 if high < EMA(high) and low < EMA(low) and high < EMA(low); -1 if high < EMA(high) and low < EMA(low); otherwise 0
Calculation: EMA envelope score = 5 for state 2, 3 for state 1, -5 for state -2, -3 for state -1, otherwise 0
Calculation: 200 EMA state = 1 if close > EMA(close), otherwise -1
Calculation: VWAP state = 1 if close > VWAP, otherwise -1
Calculation: Bias percentage = clamp((score + 39) / 78 × 100, 0, 100), where score is the sum of each of NQ, ES, and YM's EMA envelope score, plus the negated VIX EMA envelope score, plus 2 times each of NQ, ES, and YM's 200 EMA state, minus 2 times VIX's 200 EMA state, plus each of NQ, ES, and YM's VWAP state
Long: Bias percentage >= 60
Short: Bias percentage < 40