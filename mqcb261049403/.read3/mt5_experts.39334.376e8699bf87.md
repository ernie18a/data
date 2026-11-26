Long: On chart bars, DeMarker(lookback, T1, last completed bar) < lower threshold AND (time control is disabled OR current time is within the configured entry window)
Short: On chart bars, DeMarker(lookback, T1, last completed bar) > upper threshold AND (time control is disabled OR current time is within the configured entry window)
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance