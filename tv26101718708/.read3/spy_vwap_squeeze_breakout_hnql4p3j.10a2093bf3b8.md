Calculation: Squeeze fired = (lower Bollinger Band(close, BB lookback, BB deviation) < SMA(close, KC lookback) - SMA(true range, KC lookback) * KC multiplier OR upper Bollinger Band(close, BB lookback, BB deviation) > SMA(close, KC lookback) + SMA(true range, KC lookback) * KC multiplier) AND lower Bollinger Band(close, BB lookback, BB deviation)[1] > SMA(close, KC lookback)[1] - SMA(true range, KC lookback)[1] * KC multiplier AND upper Bollinger Band(close, BB lookback, BB deviation)[1] < SMA(close, KC lookback)[1] + SMA(true range, KC lookback)[1] * KC multiplier
Long: close > VWAP(close) AND Squeeze fired AND close > open
Short: close < VWAP(close) AND Squeeze fired AND close < open
Exit: long, close < VWAP(close)
Exit: short, close > VWAP(close)