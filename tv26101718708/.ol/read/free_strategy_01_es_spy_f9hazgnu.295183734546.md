Calculation: OHLC average = (open + high + low + close) / 4
Calculation: bars since entry = 0 while flat; otherwise prior value + 1
Calculation: profit-close count = 0 while flat; otherwise prior value + 1 when close > entry price and bars since entry > 1, else prior value
Long: flat AND close < EMA(close, lookback) AND open > OHLC average AND volume <= prior bar volume AND (close < MIN(prior bar open, prior bar close) OR close > MAX(prior bar open, prior bar close))
Exit: Long, bars since entry - 1 >= maximum total bars OR profit-close count >= maximum profit closes