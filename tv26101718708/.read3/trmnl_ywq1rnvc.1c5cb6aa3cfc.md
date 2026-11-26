Calculation: positive money flow = SMA(close - low - (high - close), money-flow lookback)
Calculation: strong bullish candle = close > open AND close - low > high - close
Long: close crosses above WMA(close, short lookback) AND ADX(high, low, close, DI lookback, ADX smoothing) > ADX threshold AND close > EMA(close, long lookback) AND RSI(close, RSI lookback) > long RSI threshold AND positive money flow > 0 AND strong bullish candle AND SMA(Stochastic(RSI(close, RSI lookback), RSI(close, RSI lookback), RSI(close, RSI lookback), stochastic lookback), smoothing lookback) < stochastic RSI threshold
Short: close crosses below WMA(close, short lookback) AND DI−(high, low, close, DI lookback) > DI+(high, low, close, DI lookback)
Exit: long, close crosses below WMA(close, short lookback) × stop multiplier AND close > EMA(close, long lookback)
Exit: long, RSI(close, RSI lookback) crosses above lower take-profit threshold OR RSI(close, RSI lookback) crosses above upper take-profit threshold