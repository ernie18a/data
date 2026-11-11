Calculation: Upper zone boundary = SMA of the rolling highest value of the rolling median of high; the highest-value lookback is shorter than the SMA lookback.
Calculation: Lower zone boundary = SMA of the rolling lowest value of the rolling median of low; use the same respective lookbacks as the upper zone boundary.
Calculation: Zone center = (upper zone boundary + lower zone boundary) / 2.
Long: Close >= highest close of the preceding bars.
Short: Close < highest close of the preceding bars.
Long: Low > upper zone boundary OR (low > zone center AND low < upper zone boundary).
Short: High < lower zone boundary OR (high < zone center AND high > lower zone boundary).
Long: Short-term SMA of (high + low) / 2 > middle-term SMA of (high + low) / 2 AND short-term SMA of (high + low) / 2 > its previous value AND middle-term SMA of (high + low) / 2 != long-term SMA of (high + low) / 2.
Short: Short-term SMA of (high + low) / 2 < middle-term SMA of (high + low) / 2 AND short-term SMA of (high + low) / 2 < its previous value AND middle-term SMA of (high + low) / 2 != long-term SMA of (high + low) / 2.
Long: Close >= highest close of the preceding bars AND volume > a multiple of the median volume of preceding bars.
Short: Close < highest close of the preceding bars AND volume > a multiple of the median volume of preceding bars.