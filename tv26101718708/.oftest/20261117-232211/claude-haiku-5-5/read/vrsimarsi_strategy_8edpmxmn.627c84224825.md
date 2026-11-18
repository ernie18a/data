Calculation: RMA(x, n) = (RMA(x, n)[1] * (n - 1) + x) / n
Calculation: RSI(s, n) = 100 if RMA(max(s[1] - s, 0), n) = 0; else 0 if RMA(max(s - s[1], 0), n) = 0; else 100 - 100 / (1 + RMA(max(s - s[1], 0), n) / RMA(max(s[1] - s, 0), n))
Calculation: MARSI(s, n, m) = SMA(RSI(s, n), m)
Long: MARSI(close, RSI_lookback_close, MA_lookback_close) > MARSI(close, RSI_lookback_close, MA_lookback_close)[1]
Short: MARSI(close, RSI_lookback_close, MA_lookback_close) < MARSI(close, RSI_lookback_close, MA_lookback_close)[1]
Long: MARSI(close, RSI_lookback_close, MA_lookback_close) - MARSI(volume, RSI_lookback_volume, MA_lookback_volume) crosses above 0
Short: MARSI(close, RSI_lookback_close, MA_lookback_close) - MARSI(volume, RSI_lookback_volume, MA_lookback_volume) crosses below 0