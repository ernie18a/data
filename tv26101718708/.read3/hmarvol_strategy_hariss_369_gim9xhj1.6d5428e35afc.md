Long: close > HMA(close, HMA lookback)
Short: close <= HMA(close, HMA lookback)
Long: close > HMA(close, HMA lookback) AND RVOL(volume, RVOL lookback; current chart bar volume divided by SMA(volume, RVOL lookback) from the previous completed chart bar) > RVOL threshold
Short: close < HMA(close, HMA lookback) AND RVOL(volume, RVOL lookback; current chart bar volume divided by SMA(volume, RVOL lookback) from the previous completed chart bar) > RVOL threshold
Exit: long, SL/TP enabled AND (low <= entry price * (1 - stop-loss percentage / 100) OR high >= entry price * (1 + take-profit percentage / 100))
Exit: short, SL/TP enabled AND (high >= entry price * (1 + stop-loss percentage / 100) OR low <= entry price * (1 - take-profit percentage / 100))