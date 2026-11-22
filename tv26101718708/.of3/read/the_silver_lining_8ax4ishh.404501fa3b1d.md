Calculation: Gold/silver ratio = T1 gold close / T1 silver close, using T1 values on chart bars (the T1 bar still forming in real time and the last completed T1 bar historically)
Calculation: Baseline ratio = selected MA of gold close on T1 bars / selected MA of silver close on T1 bars, using the same baseline lookback and type for both; if VWMA is unavailable for either feed, use EMA for that feed; read on chart bars from the T1 bar still forming in real time and the last completed T1 bar historically
Calculation: Silver edge = (1 - gold/silver ratio / baseline ratio) * 100
Calculation: Lower ratio boundary = EMA(nearest-rank percentile of gold/silver ratio over the percentile lookback at the lower percentile rank, percentile smoothing lookback), calculated on chart bars using the T1 ratio values
Calculation: Upper ratio boundary = EMA(nearest-rank percentile of gold/silver ratio over the percentile lookback at the upper percentile rank, percentile smoothing lookback), calculated on chart bars using the T1 ratio values
Calculation: Ratio conflict = absolute value of silver edge <= neutral band AND (gold/silver ratio <= lower ratio boundary OR gold/silver ratio >= upper ratio boundary)
Calculation: Silver regime = NOT ratio conflict AND (silver edge >= extreme edge OR (silver edge >= strong edge AND gold/silver ratio <= lower ratio boundary) OR silver edge >= neutral band)
Calculation: Gold regime = NOT ratio conflict AND (silver edge <= -extreme edge OR (silver edge <= -strong edge AND gold/silver ratio >= upper ratio boundary) OR silver edge <= -neutral band)
Calculation: Silver edge velocity = EMA(silver edge - silver edge one chart bar ago, velocity lookback)
Long: Silver regime
Short: Gold regime
Exit: long, Silver regime AND silver edge velocity < 0 AND (absolute value of silver edge >= strong edge OR gold/silver ratio <= lower ratio boundary)
Exit: short, Gold regime AND silver edge velocity > 0 AND (absolute value of silver edge >= strong edge OR gold/silver ratio >= upper ratio boundary)
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