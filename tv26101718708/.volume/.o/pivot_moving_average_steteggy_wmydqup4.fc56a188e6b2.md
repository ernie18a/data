Calculation: Confirmed pivot high/low = a bar’s high/low that remains the highest/lowest across the configured left and right bars; available after the right bars complete.
Calculation: Pivot sequence a,b,c,d,e = latest confirmed pivot followed by the four preceding alternating pivots retained by the strategy’s same-type pivot filtering.
Calculation: Higher high = a>b, a>c, c>b, and c>d.
Calculation: Lower low = a<b, a<c, c<b, and c<d.
Calculation: Higher low = [a≥c, b>c, b>d, d>c, and d>e] OR [a<b, a>c, and b<d].
Calculation: Lower high = [a≤c, b<c, b<d, d<c, and d<e] OR [a>b, a<c, and b>d].
Calculation: Pivot trend = 1 when close > resistance, -1 when close < support, otherwise retain the prior trend; resistance updates to the latest pivot on a lower-high marking when trend is -1 or a higher-high marking when trend is 1; support updates to the latest pivot on a higher-low marking when trend is 1 or a lower-low marking when trend is -1.
Calculation: Long-term EMA = exponential moving average of close with a longer lookback than the six short-term EMAs; the long-term lookback is 200 and the short-term lookbacks are 3, 5, 8, 13, 21, and 34.
Calculation: Short-term EMA stack up = EMA(3)>EMA(5)>EMA(8)>EMA(13)>EMA(21)>EMA(34)>long-term EMA.
Calculation: Short-term EMA stack down = EMA(3)<EMA(5)<EMA(8)<EMA(13)<EMA(21)<EMA(34)<long-term EMA.
Calculation: Hourly RSI = RSI(close, 14) from the 60-minute bar still forming.
Calculation: Hourly Supertrend direction = Supertrend direction using the configured ATR length and factor, from the 60-minute bar still forming.
Long: Higher-high marking OR higher-low marking OR [pivot trend = 1 AND short-term EMA stack up AND hourly Supertrend direction < 0 AND hourly RSI[1] > hourly RSI[2] AND chart-timeframe Supertrend value differs from its prior bar’s value].
Short: Lower-low marking OR lower-high marking OR [pivot trend ≠ 1 AND short-term EMA stack down AND hourly Supertrend direction > 0 AND hourly RSI[1] < hourly RSI[2] AND chart-timeframe Supertrend value differs from its prior bar’s value].
Exit: Long, EMA(3) crosses EMA(8) in either direction OR [EMA(3)<EMA(5) AND open profit < configured minimum profit].
Exit: Short, EMA(3) crosses EMA(8) in either direction OR [EMA(3)>EMA(5) AND open profit < configured minimum profit].