Calculation: gold/silver ratio = gold closing price at T1 / silver closing price at T1
Calculation: relative metal edge = 100 × (1 − gold/silver ratio / (selected average of gold closing price at T1 over P1 bars / selected average of silver closing price at T1 over P1 bars)); select EMA or VWMA by P2, with EMA fallback when VWMA is unavailable
Calculation: lower ratio percentile = EMA over P9 bars of the rank-P7 nearest-rank percentile of the gold/silver ratio over P3 bars
Calculation: upper ratio percentile = EMA over P9 bars of the rank-P8 nearest-rank percentile of the gold/silver ratio over P3 bars
Calculation: edge momentum = EMA of the relative metal edge change over P6 bars
Calculation: silver-favoring regime = relative metal edge > P4 OR (relative metal edge = P4 AND gold/silver ratio > lower ratio percentile AND gold/silver ratio < upper ratio percentile)
Calculation: gold-favoring regime = relative metal edge < −P4 OR (relative metal edge = −P4 AND gold/silver ratio > lower ratio percentile AND gold/silver ratio < upper ratio percentile)
Long: silver-favoring regime
Short: gold-favoring regime
Long: relative metal edge crosses above 0
Short: relative metal edge crosses below 0
Exit: long, silver-favoring regime AND edge momentum < 0 AND (absolute relative metal edge ≥ P5 OR gold/silver ratio ≤ lower ratio percentile)
Exit: short, gold-favoring regime AND edge momentum > 0 AND (absolute relative metal edge ≥ P5 OR gold/silver ratio ≥ upper ratio percentile)