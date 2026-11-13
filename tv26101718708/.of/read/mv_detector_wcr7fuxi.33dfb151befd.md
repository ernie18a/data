Calculation: MA_s, MA_m, MA_l = SMA of close with lengths short < medium < long
Calculation: RS = close / close of a benchmark index (same timeframe as chart, same bar)
Calculation: Range(n) = highest high over last n bars - lowest low over last n bars
Calculation: ATRpct = ATR / close * 100
Calculation: PriorHigh = highest high over the N bars before the current bar (current bar excluded)
Long: close > MA_m AND close > MA_l AND MA_m > MA_l AND MA_l > MA_l from a fixed number of bars ago AND MA_s > MA_m AND MA_s > MA_l AND close > MA_s AND close >= a fixed fraction (<1) of the highest high over a long lookback AND close >= a fixed multiple (>1) of the lowest low over the same long lookback AND RS > SMA(RS) AND RS > RS from a fixed number of bars ago AND Range(shorter lookback) < a fixed fraction (<1) of Range(longer lookback) AND ATRpct < SMA(ATRpct) AND (close - MA_s) / MA_s * 100 <= a maximum extension AND close > PriorHigh AND volume > a fixed multiple (>1) of SMA(volume)