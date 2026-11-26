Calculation: M_i = selected MA(close, separate lookback_i), i = 1..12, using one shared selectable MA type
Calculation: MA mean = (M_1 + M_2 + M_3 + M_4 + M_5 + M_6 + M_7 + M_8 + M_9 + M_10 + M_11 + M_12) / 12
Calculation: Uptrend touch price = when close > MA mean and M_5 > M_6 > M_7 > M_8, the first M_(i+1) for i = 1..11 where M_i >= low >= M_(i+1); otherwise undefined
Calculation: Downtrend touch price = when close < MA mean and M_5 < M_6 < M_7 < M_8, the first M_(i+1) for i = 1..11 where M_i <= high <= M_(i+1); otherwise undefined
Calculation: Long stop = if low < low[1], current uptrend touch price when defined, otherwise (previous uptrend touch price + low) / 2; otherwise previous uptrend touch price
Calculation: Short stop = if high > high[1], current downtrend touch price when defined, otherwise (previous downtrend touch price + high) / 2; otherwise previous downtrend touch price
Calculation: Initial long target = entry price + abs(entry price - long stop) * profit-factor parameter
Calculation: Initial short target = entry price - abs(entry price - short stop) * profit-factor parameter
Calculation: Active long target starts at the initial long target; on each enabled turnover-trend bar where M_1 < M_2 < M_3 < M_4, close < MA mean, and the highest high since entry > entry price, replace it with the highest high since entry
Calculation: Active short target starts at the initial short target; on each enabled turnover-trend bar where M_1 > M_2 > M_3 > M_4, close > MA mean, and the lowest low since entry < entry price, replace it with the lowest low since entry
Long: close > MA mean AND M_5 > M_6 > M_7 > M_8 AND high > high[1] AND previous uptrend touch price is defined AND long stop > 0 AND initial long target > 0 AND (flat OR (holding short AND turnover signal enabled AND (profitable-price exit disabled OR close < entry price)))
Short: close < MA mean AND M_5 < M_6 < M_7 < M_8 AND low < low[1] AND previous downtrend touch price is defined AND short stop > 0 AND initial short target > 0 AND (flat OR (holding long AND turnover signal enabled AND (profitable-price exit disabled OR close > entry price)))
Exit: long, low <= long stop OR high >= active long target
Exit: short, high >= short stop OR low <= active short target