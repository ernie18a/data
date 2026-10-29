Long: close > SMA(close) AND RSI(close) < oversold threshold AND volume > 20-period SMA(volume) × volume threshold AND ATR > previous ATR
Short: close < SMA(close) AND RSI(close) > overbought threshold AND volume > 20-period SMA(volume) × volume threshold AND ATR > previous ATR
Exit: long, high >= signal-bar close × (1 + take-profit percentage) OR low <= signal-bar close × (1 − stop-loss percentage)
Exit: short, low <= signal-bar close × (1 − take-profit percentage) OR high >= signal-bar close × (1 + stop-loss percentage)