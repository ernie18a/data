Calculation: LatestFVG(T, N, H) = direction (bullish, bearish, or none if empty) of the newest of at most N retained gaps, computed on bars of T using the last completed T bar: remove each retained bullish gap with low <= its bottom and each retained bearish gap with high >= its top; if low[0] > high[2], add a bullish gap with bottom high[2] and top low[0]; else if high[0] < low[2], add a bearish gap with top low[2] and bottom high[0]; when a gap is added, if H, first remove retained gaps overlapping it, add it as newest, and drop the oldest gaps beyond N
Long: (not T1 enabled OR LatestFVG(T1, N1, H) = bullish) AND (not T2 enabled OR LatestFVG(T2, N2, H) = bullish) AND (not T3 enabled OR LatestFVG(T3, N3, H) = bullish) AND (not T4 enabled OR LatestFVG(T4, N4, H) = bullish) AND (T1 enabled OR T2 enabled OR T3 enabled OR T4 enabled)
Short: (not T1 enabled OR LatestFVG(T1, N1, H) = bearish) AND (not T2 enabled OR LatestFVG(T2, N2, H) = bearish) AND (not T3 enabled OR LatestFVG(T3, N3, H) = bearish) AND (not T4 enabled OR LatestFVG(T4, N4, H) = bearish) AND (T1 enabled OR T2 enabled OR T3 enabled OR T4 enabled)
Long: T1 enabled AND LatestFVG(T1, N1, H) = bullish
Long: T2 enabled AND LatestFVG(T2, N2, H) = bullish
Long: T3 enabled AND LatestFVG(T3, N3, H) = bullish
Long: T4 enabled AND LatestFVG(T4, N4, H) = bullish
Short: T1 enabled AND LatestFVG(T1, N1, H) = bearish
Short: T2 enabled AND LatestFVG(T2, N2, H) = bearish
Short: T3 enabled AND LatestFVG(T3, N3, H) = bearish
Short: T4 enabled AND LatestFVG(T4, N4, H) = bearish