Calculation: Smoothed Heikin Ashi OBV = cumulative sum on chart bars of +volume when EMA(Heikin Ashi close, smoothing) > EMA(Heikin Ashi close[1], smoothing), −volume when <, and 0 when equal
Calculation: Normalized pivot volume = sum(volume, 2 × pivot-left lookback) / percentile_nearest_rank(sum(volume, 2 × pivot-left lookback), percentile lookback, percentile rank) × scaling factor
Long: pivotlow(low, pivot-left lookback, pivot-right lookback) is not na AND normalized pivot volume > volume threshold AND chart bar is confirmed
Short: pivothigh(high, pivot-left lookback, pivot-right lookback) is not na AND normalized pivot volume > volume threshold AND chart bar is confirmed
Long: smoothed Heikin Ashi OBV > EMA(smoothed Heikin Ashi OBV, slow lookback)
Short: smoothed Heikin Ashi OBV < EMA(smoothed Heikin Ashi OBV, slow lookback)
Long: smoothed Heikin Ashi OBV > EMA(smoothed Heikin Ashi OBV, slow lookback) AND EMA(smoothed Heikin Ashi OBV, fast lookback) > EMA(smoothed Heikin Ashi OBV, slow lookback)
Short: smoothed Heikin Ashi OBV < EMA(smoothed Heikin Ashi OBV, slow lookback) AND EMA(smoothed Heikin Ashi OBV, fast lookback) < EMA(smoothed Heikin Ashi OBV, slow lookback)