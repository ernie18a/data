Long: RSI(applied price, lookback, T1, still-forming bar) < lower RSI threshold
Long: RSI(applied price, lookback, T1, still-forming bar) < upper RSI threshold AND minimum entry price among open long positions - close > pending distance
Short: RSI(applied price, lookback, T1, still-forming bar) > upper RSI threshold
Short: RSI(applied price, lookback, T1, still-forming bar) > lower RSI threshold AND close - maximum entry price among open short positions > pending distance
Exit: long, high > entry price + take-profit distance OR (highest high since entry > entry price + trailing-stop distance AND low < highest high since entry - trailing-stop distance)
Exit: short, low < entry price - take-profit distance OR (entry price - lowest low since entry > trailing-stop distance AND high > lowest low since entry + trailing-stop distance)