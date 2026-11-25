Long: open[1] < VIDYA(close, CMO lookback, EMA lookback)[1] AND close[1] > VIDYA(close, CMO lookback, EMA lookback)[1]
Short: open[1] > VIDYA(close, CMO lookback, EMA lookback)[1] AND close[1] < VIDYA(close, CMO lookback, EMA lookback)[1]
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance