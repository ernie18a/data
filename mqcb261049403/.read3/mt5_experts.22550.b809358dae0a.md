Calculation: MACD main line = MACD main line(MACD applied price, MACD fast lookback, MACD slow lookback, MACD signal lookback) on T1 bars, read on each chart tick
Calculation: Stochastic signal line = Stochastic signal line(Stochastic K lookback, Stochastic D smoothing, Stochastic slowing, Stochastic MA method, Stochastic price field) on T1 bars, read on each chart tick
Calculation: RSI = RSI(RSI applied price, RSI lookback) on T1 bars, read on each chart tick
Long: open(T1, current forming bar) >= open(T1, previous bar) AND MACD main line[0] <= MACD main line[1] AND Stochastic signal line[0] <= 50 AND RSI[0] <= 50
Short: open(T1, current forming bar) <= open(T1, previous bar) AND MACD main line[0] >= MACD main line[1] AND Stochastic signal line[0] >= 50 AND RSI[0] >= 50