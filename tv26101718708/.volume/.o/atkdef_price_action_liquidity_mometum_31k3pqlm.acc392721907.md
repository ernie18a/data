Calculation: Body strength = (close − open) / (high − low), or 0 when high = low
Calculation: CMF = sum of ((2 × close − high − low) / (high − low)) × volume divided by sum of volume over its lookback; use 0 for the multiplier when high = low
Calculation: Momentum index = 0.6 × RSI of close + 0.4 × RSI of volume
Long: body strength > 0 OR CMF > 0.05 OR (momentum index > 50 AND momentum index ≤ 70) OR (CMF > 0 AND body strength > 0)
Short: body strength < 0 OR CMF < −0.05 OR (momentum index ≥ 30 AND momentum index < 50) OR (CMF < 0 AND body strength < 0)