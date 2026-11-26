Long: MA(close, selected type, lookback) >= MA(close, selected type, lookback)[smoothing lookback]
Short: MA(close, selected type, lookback) < MA(close, selected type, lookback)[smoothing lookback]
Exit: long, after high reaches entry price + trailing-stop activation distance, low <= highest high since activation - trailing-stop offset
Exit: short, after low reaches entry price - trailing-stop activation distance, high >= lowest low since activation + trailing-stop offset