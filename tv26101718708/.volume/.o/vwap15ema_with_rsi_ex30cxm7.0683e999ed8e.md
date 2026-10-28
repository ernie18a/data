Long: close > VWAP AND close > EMA AND RSI > RSI threshold
Short: RSI > RSI threshold
Exit: long, low <= entry price * (1 - stop-loss percentage) OR high >= entry price * (1 + take-profit percentage) OR low <= (highest high since entry) * (1 - trailing-stop percentage)