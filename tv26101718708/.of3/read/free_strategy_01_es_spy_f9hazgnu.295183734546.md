Calculation: bars in position = 0 while flat; otherwise previous bar's bars in position + 1
Calculation: profit closes in position = 0 while flat; otherwise previous bar's count + 1 when close > entry price and bars in position > 1, else previous bar's count
Long: position is flat AND close < EMA(close, lookback) AND open > OHLC4(open, high, low, close) AND volume <= volume[1] AND (close < min(open[1], close[1]) OR close > max(open[1], close[1]))
Exit: long, bars in position > maximum total bars OR profit closes in position >= maximum profit closes