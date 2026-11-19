Calculation: Symbol trend state at timeframe T = 1 when symbol closing price > EMA(symbol closing price, fast EMA length) AND EMA(symbol closing price, fast EMA length) > EMA(symbol closing price, slow EMA length) AND RSI(symbol closing price, RSI length) > RSI threshold; -1 when symbol closing price < EMA(symbol closing price, fast EMA length) AND EMA(symbol closing price, fast EMA length) < EMA(symbol closing price, slow EMA length) AND RSI(symbol closing price, RSI length) < RSI threshold; otherwise 0
Long: Enabled symbol trend state at T1, T2, T3, or T4 = 1
Short: Enabled symbol trend state at T1, T2, T3, or T4 = -1
Calculation: Market trend score = sum of enabled symbols' trend states at T1, T2, T3, and T4
Calculation: Maximum market trend score = enabled-symbol count × number of timeframes
Long: Enabled-symbol count > 0 AND market trend score >= maximum market trend score × risk-bias threshold
Short: Enabled-symbol count > 0 AND market trend score <= -maximum market trend score × risk-bias threshold