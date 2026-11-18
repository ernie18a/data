Calculation: Smoothed Heikin-Ashi OBV = cumulative sum of volume when EMA(Heikin-Ashi close, smoothing) > EMA(Heikin-Ashi close[1], smoothing), 0 when equal, and −volume otherwise
Long: Smoothed Heikin-Ashi OBV > EMA(Smoothed Heikin-Ashi OBV, slow lookback)
Short: Smoothed Heikin-Ashi OBV < EMA(Smoothed Heikin-Ashi OBV, slow lookback)