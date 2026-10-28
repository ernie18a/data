Calculation: candle body low = min(open, close)
Calculation: lower average = min(short-term SMA, intermediate-term EMA)
Long: VWAP > intermediate-term EMA OR (position is flat AND candle body low > short-term SMA)
Short: VWAP < intermediate-term EMA
Exit: long, VWAP < intermediate-term EMA OR close < lower average
Exit: short, VWAP > intermediate-term EMA