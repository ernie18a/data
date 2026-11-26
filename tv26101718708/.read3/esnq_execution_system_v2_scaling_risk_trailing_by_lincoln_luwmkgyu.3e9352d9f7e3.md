Calculation: sweep below(level) = low < level AND close > level
Calculation: sweep above(level) = high > level AND close < level
Calculation: prior T1 high/low = high/low of the last completed T1 bar, sampled on each chart bar
Calculation: premarket high/low = highest high/lowest low of chart bars in the premarket interval, reset each day
Calculation: opening-range high/low = highest high/lowest low of chart bars in the opening-range interval, reset each day
Calculation: ATR buffer = ATR(ATR lookback) * stop-buffer multiplier
Calculation: long risk = current close - (current low - ATR buffer)
Calculation: short risk = (current high + ATR buffer) - current close
Calculation: long target = current close + target multiple * long risk
Calculation: short target = current close - target multiple * short risk
Calculation: long stop = current low - ATR buffer on entry; thereafter the greatest of the prior long stop and entry price if close >= entry price + breakeven multiple * long risk and close - ATR buffer if close >= long target
Calculation: short stop = current high + ATR buffer on entry; thereafter the least of the prior short stop and entry price if close <= entry price - breakeven multiple * short risk and close + ATR buffer if close <= short target
Long: trade count since the current day began < daily trade limit AND chart bar is in the entry interval AND at least the minimum sweep count of sweep below(prior T1 low), sweep below(premarket low), and sweep below(opening-range low)
Short: trade count since the current day began < daily trade limit AND chart bar is in the entry interval AND at least the minimum sweep count of sweep above(prior T1 high), sweep above(premarket high), and sweep above(opening-range high)
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target