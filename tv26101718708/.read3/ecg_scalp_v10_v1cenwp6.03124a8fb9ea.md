Calculation: T1 bullish trend = On chart bars, EMA(close, middle EMA lookback, T1 requested with lookahead off; last completed historical bar or still-forming realtime bar) > EMA(close, longer EMA lookback, same T1 bar)
Calculation: T1 bearish trend = On chart bars, EMA(close, middle EMA lookback, T1 requested with lookahead off; last completed historical bar or still-forming realtime bar) < EMA(close, longer EMA lookback, same T1 bar)
Long: At least 2 of (EMA(close, shorter lookback) crosses above EMA(close, middle lookback), RSI(close, RSI lookback) > long RSI threshold, T1 bullish trend)
Short: At least 2 of (EMA(close, shorter lookback) crosses below EMA(close, middle lookback), RSI(close, RSI lookback) < short RSI threshold, T1 bearish trend)
Long: EMA(close, shorter lookback) crosses above EMA(close, middle lookback) AND RSI(close, RSI lookback) > long RSI threshold AND UTC hour(datetime) < session-end hour parameter
Short: EMA(close, shorter lookback) crosses below EMA(close, middle lookback) AND RSI(close, RSI lookback) < short RSI threshold AND UTC hour(datetime) < session-end hour parameter
Long: T1 bullish trend
Short: T1 bearish trend
Long: VWAP > VWAP threshold parameter
Short: VWAP < VWAP threshold parameter
Exit: Long, high >= entry price × (1 + profit-target percentage parameter) OR low <= entry price × (1 - stop-loss percentage parameter)
Exit: Short, low <= entry price × (1 - profit-target percentage parameter) OR high >= entry price × (1 + stop-loss percentage parameter)