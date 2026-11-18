Long: current bar open < SMA(close, lookback, shift) AND current bar close > SMA(close, lookback, shift)
Short: current bar open > SMA(close, lookback, shift) AND current bar close < SMA(close, lookback, shift)
Exit: long, current bar low <= entry price - stop-loss distance OR current bar high >= entry price + take-profit distance
Exit: short, current bar high >= entry price + stop-loss distance OR current bar low <= entry price - take-profit distance