Long: Fast EMA > Slow EMA AND previous Fast EMA <= previous Slow EMA AND RSI < overbought threshold AND close > VWAP AND within the trading session
Short: Fast EMA < Slow EMA AND previous Fast EMA >= previous Slow EMA AND RSI > oversold threshold AND close < VWAP AND within the trading session
Exit: long, low <= entry price * (1 - stop-loss percentage) OR high >= entry price * (1 + take-profit percentage) OR outside the trading session
Exit: short, high >= entry price * (1 + stop-loss percentage) OR low <= entry price * (1 - take-profit percentage) OR outside the trading session