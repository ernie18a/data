Calculation: market-leader breadth = sum 1 for each of SPX, QQQ, AAPL, MSFT, GOOG, FB, BRK.A, TSLA, V, JPM, WMT, UNH, MA, KO, PYPL, PG, HD, DIS, BAC, ADBE, CMCSA, and NKE whose OHLC4 is above its SMA(N1), and -1 otherwise
Long: market-leader breadth crosses above 0
Long: market-leader breadth > 0 AND chart close > SMA(chart close,N1) AND prior chart close > current SMA(chart close,N1) AND no open position
Exit: long, market-leader breadth < 0
Exit: long, traded-instrument price <= entry price × (1 - P1)