Calculation: premarket high = highest high during the current premarket session, reset at the start of each trading day
Calculation: highest high since entry = highest high from the entry bar through the current bar
Calculation: hard stop = entry price - stop offset
Calculation: ATR trailing stop = highest high since entry - ATR(high, low, close, ATR lookback) * ATR multiple
Calculation: active stop = max(hard stop, ATR trailing stop)
Long: flat AND more than the cooldown period in bars since the last exit AND volume / (SMA(volume, RVOL lookback) if positive, otherwise 1) >= RVOL threshold AND close > VWAP(close) AND close > EMA(close, EMA lookback) AND close > premarket high AND (close[1] < open[1] OR close[1] < EMA(close, EMA lookback)[1]) AND close > high[1] AND price floor <= close <= price ceiling
Exit: long, close < active stop OR low < hard stop OR close crosses below VWAP(close)