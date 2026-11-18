Calculation: flow = (close - close[1]) * volume / SMA(volume, volume lookback)
Long: RSI(EMA(flow, smoothing), momentum lookback) crosses above lower threshold OR RSI(EMA(flow, smoothing), momentum lookback) > upper threshold
Short: RSI(EMA(-flow, smoothing), momentum lookback) > upper threshold