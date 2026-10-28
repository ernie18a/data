Calculation: Volume flow = EMA(EMA(buy volume − sell volume, volume-smoothing lookback) / (EMA(volume, same lookback) + 0.000001), flow-smoothing lookback), where buy volume is volume when close > previous close, otherwise 0, and sell volume is volume when close < previous close, otherwise 0
Calculation: Signal line = EMA(volume flow, signal lookback)
Long: Volume flow crosses above the signal line
Short: Volume flow crosses below the signal line