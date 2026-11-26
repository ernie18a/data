Long: position side = flat AND Momentum(close, lookback) < 100 - parameter
Short: position side = flat AND Momentum(close, lookback) > 100 + parameter
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance