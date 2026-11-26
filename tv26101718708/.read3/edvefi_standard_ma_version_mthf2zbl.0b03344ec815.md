Calculation: Adjusted force index = EMA(volume * (((wick weight / 10) * (2 * close - (max(high, close[1]) + min(low, close[1]))) + (1 - wick weight / 10) * (close - close[1])) / normalization denominator), EFI lookback), where normalization denominator is 1 when normalization is disabled, max(max(high, close[1]) - min(low, close[1]), epsilon) when normalized by spread, or max(close[1], epsilon) when normalized by previous-bar price
Long: Adjusted force index > SMA(Adjusted force index, smoothing lookback)
Short: Adjusted force index < SMA(Adjusted force index, smoothing lookback)
Long: SMA(Adjusted force index, smoothing lookback) > 0
Short: SMA(Adjusted force index, smoothing lookback) <= 0