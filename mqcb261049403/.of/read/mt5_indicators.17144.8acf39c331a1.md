Calculation: NEMA(price, period, depth) = the sum over k=1 to depth of (-1)^(k-1) × binomial(depth, k) × the result of applying EMA(price, period) recursively k times; EMA uses alpha = 2/(period+1). Use the same depth for all NEMA calculations. Calculate on the chart timeframe or the specified higher timeframe and use the bar still forming at the decision time.
Calculation: NEMA MACD = NEMA of price with the shorter fast period minus NEMA of price with the longer slow period.
Calculation: MACD signal = NEMA of NEMA MACD using the signal period.
Long: NEMA MACD > MACD signal
Short: NEMA MACD < MACD signal