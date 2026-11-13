Calculation: T1..T4 = four timeframes; T1 = chart timeframe (current bar), T2 < T3 < T4 each higher than the chart timeframe and than the previous one, all using the last completed bar
Calculation: Stochastic K = 3-bar SMA of raw stochastic (close vs. high/low over a lookback); D = 3-bar SMA of K
Calculation: ADX, +DI, -DI = standard DMI/ADX
Calculation: RVOL = volume / SMA(volume, lookback)
Calculation: Trend = fast EMA(close) > slow EMA(close) (fast lookback shorter than slow lookback); Mom = RSI > 50; Macd = MACD line > MACD signal line; Stoch = K > D
Calculation: BullScore(T) = 20*Trend + 20*Mom + 20*Macd + 20*Stoch + 10*(+DI > -DI AND ADX > trend-strength threshold) + 10*(RVOL > 1 AND Trend), each evaluated on timeframe T
Calculation: BearScore(T) = 20*NOT Trend + 20*NOT Mom + 20*NOT Macd + 20*NOT Stoch + 10*(-DI > +DI AND ADX > trend-strength threshold) + 10*(RVOL > 1 AND NOT Trend), each evaluated on timeframe T
Calculation: AvgBull = mean of BullScore over T1..T4; AvgBear = mean of BearScore over T1..T4
Long: AvgBull >= global threshold AND BullScore(T1) >= strong threshold AND RVOL(T1) > 1 AND BullScore(T2) >= strong threshold AND RVOL(T2) > 1 (global threshold < strong threshold)
Long: AvgBull >= global threshold
Long: BullScore(Ti) >= strong threshold for any i in T1..T4
Short: AvgBear >= global threshold AND BearScore(T1) >= strong threshold AND RVOL(T1) > 1 AND BearScore(T2) >= strong threshold AND RVOL(T2) > 1
Short: AvgBear >= global threshold
Short: BearScore(Ti) >= strong threshold for any i in T1..T4