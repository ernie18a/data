Long: no open position AND close > EMA(close, EMA lookback) AND RSI(close, RSI lookback) > long RSI threshold
Short: no open position AND close < EMA(close, EMA lookback) AND RSI(close, RSI lookback) < short RSI threshold
Long: long position exists AND lowest long entry price - close > grid distance × point size
Short: short position exists AND close - highest short entry price > grid distance × point size
Exit: long or short, total open-position profit >= profit target
Exit: long or short, total open-position profit <= -risk limit