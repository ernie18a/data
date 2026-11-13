Long: EMA(close, short lookback) crosses above EMA(close, long lookback) on the current bar AND RSI(close) < upper RSI threshold AND volume > SMA(volume)
Long: EMA(close, short lookback) > EMA(close, long lookback)
Short: EMA(close, short lookback) crosses below EMA(close, long lookback) on the current bar AND RSI(close) > lower RSI threshold (lower than the upper threshold) AND volume > SMA(volume)
Short: EMA(close, short lookback) < EMA(close, long lookback)
Exit: short, the first Long condition (EMA cross-up with RSI and volume filters) is true; close at the close price and reverse to long
Exit: long, the first Short condition (EMA cross-down with RSI and volume filters) is true; close at the close price and reverse to short