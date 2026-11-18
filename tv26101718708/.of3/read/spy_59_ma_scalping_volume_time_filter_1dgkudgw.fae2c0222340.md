Long: SMA(close, shorter lookback) crosses above SMA(close, longer lookback) AND volume > volume[1] AND datetime in the entry window (inclusive, America/New_York)
Short: SMA(close, shorter lookback) crosses below SMA(close, longer lookback) AND volume > volume[1] AND datetime in the entry window (inclusive, America/New_York)
Exit: long, high >= entry price + take-profit distance OR low <= entry price - stop-loss distance
Exit: short, low <= entry price - take-profit distance OR high >= entry price + stop-loss distance