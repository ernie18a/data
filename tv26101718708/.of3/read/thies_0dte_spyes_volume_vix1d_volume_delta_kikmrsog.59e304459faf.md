Calculation: combined signed volume = sum of volume when close >= open, otherwise negative volume, across component series
Calculation: combined volume = sum of volume across component series
Long: EMA(combined signed volume, smoothing lookback) >= 0
Short: EMA(combined signed volume, smoothing lookback) < 0
Long: EMA(combined signed volume, smoothing lookback) >= 0 AND EMA(combined signed volume, smoothing lookback) > EMA(combined signed volume, smoothing lookback)[1] AND combined volume > MA(combined volume, volume lookback) AND volatility index close <= volatility index close[1]
Short: EMA(combined signed volume, smoothing lookback) < 0 AND EMA(combined signed volume, smoothing lookback) < EMA(combined signed volume, smoothing lookback)[1] AND combined volume > MA(combined volume, volume lookback) AND volatility index close > volatility index close[1]
Exit: long, close < MA(combined volume, volume lookback) OR datetime >= exit-time parameter
Exit: short, close > MA(combined volume, volume lookback) OR datetime >= exit-time parameter