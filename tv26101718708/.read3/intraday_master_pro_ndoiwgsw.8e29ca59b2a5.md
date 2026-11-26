Long: EMA(close, shorter entry lookback) crosses above EMA(close, longer entry lookback) AND volume > SMA(volume, volume lookback) * volume multiplier AND RSI(close, RSI lookback) > RSI center threshold AND RSI(close, RSI lookback) < upper RSI threshold AND current chart bar index - most recent entry-signal bar index (initialized at zero) > cooldown parameter
Short: EMA(close, shorter entry lookback) crosses below EMA(close, longer entry lookback) AND volume > SMA(volume, volume lookback) * volume multiplier AND RSI(close, RSI lookback) < RSI center threshold AND RSI(close, RSI lookback) > lower RSI threshold AND current chart bar index - most recent entry-signal bar index (initialized at zero) > cooldown parameter
Long: On chart bars, close of the last completed T1 bar > EMA(close, T1 EMA lookback, T1, last completed bar)
Short: On chart bars, close of the last completed T1 bar <= EMA(close, T1 EMA lookback, T1, last completed bar)
Long: On chart bars, close of the last completed T2 bar > EMA(close, T2 EMA lookback, T2, last completed bar)
Short: On chart bars, close of the last completed T2 bar <= EMA(close, T2 EMA lookback, T2, last completed bar)
Long: On chart bars, EMA(close, shorter entry lookback) > EMA(close, longer entry lookback)
Short: On chart bars, EMA(close, shorter entry lookback) <= EMA(close, longer entry lookback)