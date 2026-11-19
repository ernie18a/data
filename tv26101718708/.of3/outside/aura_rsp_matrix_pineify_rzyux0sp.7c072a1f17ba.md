Calculation: Relative strength ratio = P3 × WMA((instrument close / benchmark close) / WMA(instrument close / benchmark close, P1), P1)
Calculation: Relative strength momentum = P3 × relative strength ratio / WMA(relative strength ratio, P1)
Calculation: Smoothed relative strength ratio = EMA(relative strength ratio, P2)
Calculation: Smoothed relative strength momentum = EMA(relative strength momentum, P2)
Calculation: Leadership phase = smoothed relative strength ratio > P3 AND smoothed relative strength momentum > P3
Calculation: Lagging phase = smoothed relative strength ratio <= P3 AND smoothed relative strength momentum <= P3
Long: leadership phase AND previous chart bar was not in the leadership phase
Short: lagging phase AND previous chart bar was not in the lagging phase