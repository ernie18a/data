Long: RSI(close, RSI lookback) > signal RSI threshold AND MACD(close, shorter lookback, longer lookback, signal lookback).line crosses above signal AND close > EMA(close, EMA lookback) AND volume > volume[1]
Short: RSI(close, RSI lookback) < signal RSI threshold AND MACD(close, shorter lookback, longer lookback, signal lookback).line crosses below signal AND close < EMA(close, EMA lookback) AND volume > volume[1]
Long: MACD(close, shorter lookback, longer lookback, signal lookback).line > signal AND RSI(close, RSI lookback) > upper RSI entry threshold AND close > EMA(close, EMA lookback) AND volume > SMA(volume, volume lookback)
Short: MACD(close, shorter lookback, longer lookback, signal lookback).line < signal AND RSI(close, RSI lookback) < lower RSI entry threshold AND close < EMA(close, EMA lookback) AND volume > SMA(volume, volume lookback)
Exit: long, RSI(close, RSI lookback) crosses below RSI exit threshold
Exit: short, RSI(close, RSI lookback) crosses above RSI exit threshold