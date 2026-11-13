Calculation: hlc3 = (high + low + close) / 3
Calculation: Band(m) = SMA(hlc3, n) +/- m * population standard deviation(hlc3, n) (Bollinger Bands on hlc3); Upper(m) and Lower(m) are its two edges. Both bands use the same n and the chart timeframe. m_inner < m_outer.
Calculation: stopDist = ATR (Wilder) at the signal bar x a multiplier; targetDist = stopDist x a reward multiple; E = close of the signal bar.
Long: (hlc3 crosses above Upper(m_inner) (previous hlc3 <= previous Upper(m_inner) and current hlc3 > current Upper(m_inner)) AND hlc3 < Upper(m_outer) AND hlc3 > Lower(m_outer)) OR (SMA(close, n) crosses above SMA(open, n), same n); in both cases AND bar datetime is inside the allowed trading session, on an allowed weekday, inside the date range, and not inside the daily exit window
Short: (hlc3 crosses below Lower(m_inner) (previous hlc3 >= previous Lower(m_inner) and current hlc3 < current Lower(m_inner)) AND hlc3 < Upper(m_outer) AND hlc3 > Lower(m_outer)) OR (SMA(close, n) crosses below SMA(open, n), same n); in both cases AND bar datetime is inside the allowed trading session, on an allowed weekday, inside the date range, and not inside the daily exit window
Exit: long, low <= E - stopDist OR high >= E + targetDist
Exit: short, high >= E + stopDist OR low <= E - targetDist
Exit: long, (optional trailing stop) highest high since entry >= E x (1 + activation%) AND price falls to or below highest high since entry minus trail offset (trail offset % of E < activation %)
Exit: short, (optional trailing stop) lowest low since entry <= E x (1 - activation%) AND price rises to or above lowest low since entry plus trail offset (trail offset % of E < activation %)
Exit: long or short, bar datetime is inside the daily exit window