Long: close > EMA(close) AND RSI(close) > threshold AND ADX > threshold AND volume > SMA(volume) AND bar time is within a configured trading session AND entries today < daily trade limit AND position is flat
Short: close < EMA(close) AND RSI(close) < threshold AND ADX > threshold AND volume > SMA(volume) AND bar time is within a configured trading session AND entries today < daily trade limit AND position is flat
Exit: long, high >= entry price + target distance OR low <= entry price - stop distance
Exit: short, low <= entry price - target distance OR high >= entry price + stop distance