Calculation: flow = ((2 * close - high - low) / max(high - low, minimum tick)) * volume * (volume / SMA(volume, volume lookback))
Calculation: positive-flow index = RSI(EMA(flow, flow smoothing), RSI lookback)
Calculation: inverse-flow index = RSI(EMA(-flow, flow smoothing), RSI lookback)
Calculation: displacement = abs(close - open) > SMA(high - low, range lookback) * displacement strength
Long: (positive-flow index crosses above inverse-flow index AND positive-flow index < smart-entry ceiling) OR (inverse-flow index < retail-oversold threshold AND positive-flow index > smart-strong threshold AND displacement AND close > open)
Short: inverse-flow index > retail-overbought threshold AND positive-flow index < smart-weak threshold AND displacement AND close < open
Exit: Long, positive-flow index crosses below inverse-flow index AND positive-flow index > smart-exit floor