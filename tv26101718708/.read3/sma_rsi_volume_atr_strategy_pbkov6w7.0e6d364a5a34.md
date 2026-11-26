Long: close > SMA(close, lookback) AND RSI(close, lookback) < oversold threshold AND volume > SMA(volume, lookback) * volume multiplier AND ATR(lookback) > ATR(lookback)[1]
Short: close < SMA(close, lookback) AND RSI(close, lookback) > overbought threshold AND volume > SMA(volume, lookback) * volume multiplier AND ATR(lookback) > ATR(lookback)[1]
Exit: long, high >= entry price * (1 + take-profit percentage) OR low <= entry price * (1 - stop-loss percentage)
Exit: short, low <= entry price * (1 - take-profit percentage) OR high >= entry price * (1 + stop-loss percentage)