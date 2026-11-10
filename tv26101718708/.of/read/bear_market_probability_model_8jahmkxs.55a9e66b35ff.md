Calculation: Drawdown = (close - highest close over a lookback) / highest close over that lookback.
Calculation: Technical risk score = the average of: (1) the fraction of these conditions that are true: close < longer-period SMA, close < shorter-period SMA, shorter-period SMA < longer-period SMA; (2) the fraction of these conditions that are true: chart-timeframe MACD line < its signal line, other-timeframe MACD line < its signal line; (3) 1 if RSI < a threshold, otherwise 0; (4) 1 if drawdown < a deeper negative threshold, 0.5 if drawdown < a shallower negative threshold, otherwise 0. The other MACD timeframe may be higher or lower than the chart timeframe; use its last completed bar.
Long: technical risk score <= lower threshold
Short: technical risk score > higher threshold
Long: close >= longer-period SMA
Short: close < longer-period SMA
Long: MACD line >= MACD signal line
Short: MACD line < MACD signal line
Long: drawdown >= shallower negative threshold
Short: drawdown < deeper negative threshold
Long: RSI < lower threshold
Short: RSI > higher threshold