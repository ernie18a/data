Calculation: volatility condition = ATR(ATR lookback) >= SMA(ATR(ATR lookback), ATR lookback) * ATR multiplier
Calculation: volume condition = volume filter off OR volume > SMA(volume, volume MA lookback) * volume factor
Long: RSI(close, RSI lookback) crosses above RSI oversold level AND close > EMA(close, shorter EMA lookback) AND volatility condition AND volume condition
Long: RSI(close, RSI lookback) < long-side RSI low level AND close crosses above EMA(close, shorter EMA lookback) AND volatility condition
Long: EMA(close, shorter EMA lookback) crosses above EMA(close, longer EMA lookback) AND RSI(close, RSI lookback) < long-side RSI high level AND volatility condition
Short: RSI(close, RSI lookback) crosses below RSI overbought level AND close < EMA(close, shorter EMA lookback) AND volatility condition AND volume condition
Short: RSI(close, RSI lookback) > short-side RSI high level AND close crosses below EMA(close, shorter EMA lookback) AND volatility condition
Short: EMA(close, shorter EMA lookback) crosses below EMA(close, longer EMA lookback) AND RSI(close, RSI lookback) > short-side RSI low level AND volatility condition