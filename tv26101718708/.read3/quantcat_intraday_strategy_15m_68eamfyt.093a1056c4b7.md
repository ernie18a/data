Calculation: MA cross count = SUM(1 when close crosses SMA(close, shorter lookback), count lookback)
Calculation: Long stop = long-entry-signal-bar close - ATR(ATR lookback, T1, still-forming bar sampled on chart bars) × stop multiple, fixed while long
Calculation: Short stop = short-entry-signal-bar close + ATR(ATR lookback, T1, still-forming bar sampled on chart bars) × stop multiple, fixed while short
Long: SMA(close, shorter lookback) crosses above SMA(close, longer lookback) OR (close < SMA(close, shorter lookback) AND close > SMA(close, longer lookback) AND SMA(close, shorter lookback) > SMA(close, longer lookback)) AND MA cross count <= maximum crosses
Short: SMA(close, shorter lookback) crosses below SMA(close, longer lookback) OR (close > SMA(close, shorter lookback) AND close < SMA(close, longer lookback) AND SMA(close, shorter lookback) < SMA(close, longer lookback)) AND MA cross count <= maximum crosses
Exit: Long, low <= Long stop
Exit: Short, high >= Short stop