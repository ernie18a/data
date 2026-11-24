Long: Twiggs Money Flow(close, high, low, volume, lookback) >= 0
Short: Twiggs Money Flow(close, high, low, volume, lookback) < 0
Long: Twiggs Money Flow(close, high, low, volume, lookback)[1] > Twiggs Money Flow(close, high, low, volume, lookback)[2]
Short: Twiggs Money Flow(close, high, low, volume, lookback)[1] <= Twiggs Money Flow(close, high, low, volume, lookback)[2]
Long: Twiggs Money Flow(close, high, low, volume, lookback)[1] >= RMA(Twiggs Money Flow(close, high, low, volume, lookback), signal lookback)[1]
Short: Twiggs Money Flow(close, high, low, volume, lookback)[1] < RMA(Twiggs Money Flow(close, high, low, volume, lookback), signal lookback)[1]
Long: Twiggs Money Flow(close, high, low, volume, lookback) crosses above RMA(Twiggs Money Flow(close, high, low, volume, lookback), signal lookback)
Long: Twiggs Money Flow(close, high, low, volume, lookback)[2] < 0 AND Twiggs Money Flow(close, high, low, volume, lookback)[1] >= 0
Short: Twiggs Money Flow(close, high, low, volume, lookback)[2] >= 0 AND Twiggs Money Flow(close, high, low, volume, lookback)[1] < 0
Long: close[1] > latest active PivotHigh(high, swing lookback, swing lookback)
Short: close[1] < latest active PivotLow(low, swing lookback, swing lookback)