Calculation: OsMA direction = sign(OsMA(close, shorter lookback, longer lookback, signal lookback)[last completed chart bar] - OsMA(close, shorter lookback, longer lookback, signal lookback)[preceding chart bar])
Long: OsMA direction = -1 AND Force Index(close, volume, lookback, moving average method)[last completed chart bar] > 0
Short: OsMA direction = 1 AND Force Index(close, volume, lookback, moving average method)[last completed chart bar] < 0
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance