Long: market-series close > EMA(market-series close, market EMA lookback), calculated on T1 bars and sampled on chart bars using the last completed T1 bar historically or the still-forming T1 bar in realtime, AND (SMA(RSI(close, RSI lookback), RSI smoothing lookback) > buy threshold OR RSI(close, RSI lookback) > buy threshold)
Exit: Long, crossunder(close, WMA(close, WMA lookback)) OR RSI(close, RSI lookback) < sell threshold
Long: BTCUSD close(T1) > EMA(BTCUSD close(T1), P1) AND SMA(RSI(close, P2), P3) > P4
Long: BTCUSD close(T1) > EMA(BTCUSD close(T1), P1) AND RSI(close, P5) > P6