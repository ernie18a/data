Calculation: smoothed volume-weighted center = EMA(VWMA(close, channel lookback), smoothing lookback)
Long: close crosses above EMA(VWMA(close, channel lookback) + ATR(channel lookback) * band multiplier, smoothing lookback)
Short: close crosses below EMA(VWMA(close, channel lookback) - ATR(channel lookback) * band multiplier, smoothing lookback)
Long: close > smoothed volume-weighted center
Short: close <= smoothed volume-weighted center