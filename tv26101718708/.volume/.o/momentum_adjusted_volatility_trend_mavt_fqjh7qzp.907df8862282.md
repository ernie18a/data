Calculation: MAVT line = 100 × rolling min-max normalization of ((rolling min-max normalized fast EMA(close) − slow EMA(close)) × rolling min-max normalized (volume / SMA(volume)) / (1 + rolling min-max normalized ATR)); fast EMA period is shorter than slow EMA period; each min-max normalization uses the same lookback.
Calculation: Histogram = MAVT line − EMA(MAVT line); EMA period is the signal period.
Long: MAVT line > 50 OR (Histogram ≥ 0 AND Histogram > previous Histogram)
Short: MAVT line ≤ 50 OR (Histogram < 0 AND Histogram < previous Histogram)
Exit: long, Histogram ≥ 0 AND Histogram ≤ previous Histogram
Exit: short, Histogram < 0 AND Histogram ≥ previous Histogram