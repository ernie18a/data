Calculation: OBV = cumulative sum of volume, adding volume when close > previous close, subtracting volume when close < previous close, and adding 0 when equal
Calculation: Osc = 50 + 50 * (OBV - EMA(OBV)) / (highest absolute value of (OBV - EMA(OBV)) over a lookback); equals 50 if that highest absolute value is 0; clamped to the range 0 to 100; optionally EMA-smoothed (a smoothing length of 1 means no smoothing); the EMA(OBV) length is shorter than the normalization lookback
Long: Osc >= 50
Short: Osc < 50