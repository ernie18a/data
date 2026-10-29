Calculation: Normalized ATR = (ATR − lowest ATR over a lookback) / (highest ATR over the same lookback − lowest ATR over the same lookback)
Calculation: Smoothed close = RMA(close, a lookback)
Calculation: Stop-loss fraction = one parameter when close > a longer-lookback EMA, otherwise another parameter
Calculation: Take-profit fraction = one parameter when close > a longer-lookback EMA, otherwise another parameter
Long: Bullish Supertrend direction AND shorter-lookback EMA crosses above longer-lookback EMA AND normalized ATR > bullish threshold OR bearish Supertrend direction AND shorter-lookback EMA crosses above longer-lookback EMA AND normalized ATR > bearish threshold
Exit: Long, (shorter-lookback EMA crosses below longer-lookback EMA OR smoothed close > threshold) AND bars since entry ≥ minimum holding period AND volume > its SMA over a lookback multiplied by a parameter OR low ≤ entry price × (1 − stop-loss fraction) OR high ≥ entry price × (1 + take-profit fraction)