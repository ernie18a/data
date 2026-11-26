Long: close crosses above HMA(close, chart HMA lookback) AND Heikin-Ashi close > Heikin-Ashi open AND close > Supertrend(factor, ATR lookback) AND volume >= SMA(volume, volume lookback) * volume multiplier AND (close > Volume Point of Control OR close > EMA(close, long EMA lookback)) AND RSI(close, RSI lookback) < entry RSI ceiling AND CCI(close, CCI lookback) > CCI threshold
Long: HMA(close, chart HMA lookback) > HMA(close, chart HMA lookback)[1]
Short: HMA(close, chart HMA lookback) <= HMA(close, chart HMA lookback)[1]
Long: Supertrend(factor, ATR lookback) direction is uptrend
Short: Supertrend(factor, ATR lookback) direction is downtrend
Long: On chart bars, chart close crosses above HMA(close, T1 HMA lookback, T1, still-forming bar) AND RSI(close, RSI lookback, T1, still-forming bar) > long filter threshold
Short: On chart bars, chart close crosses below HMA(close, T1 HMA lookback, T1, still-forming bar) AND RSI(close, RSI lookback, T1, still-forming bar) < short filter threshold
Long: Heikin-Ashi close > Heikin-Ashi open
Short: Heikin-Ashi close <= Heikin-Ashi open
Exit: long, close crosses below Supertrend(factor, ATR lookback) OR (close crosses below HMA(close, chart HMA lookback) AND RSI(close, RSI lookback) > exit RSI threshold)