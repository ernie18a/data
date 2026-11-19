Calculation: Demand zone = [low[1], high[1]] on a zone-creation bar where close > open
Calculation: Supply zone = [low[1], high[1]] on a zone-creation bar where close <= open
Calculation: Long entry price = zone top - (zone top - zone bottom) * entry-depth parameter
Calculation: Short entry price = zone bottom + (zone top - zone bottom) * entry-depth parameter
Calculation: Long stop price = zone bottom - ATR(ATR lookback) * stop-buffer parameter
Calculation: Short stop price = zone top + ATR(ATR lookback) * stop-buffer parameter
Calculation: Long target price = long entry price + (long entry price - long stop price) * reward-to-risk parameter
Calculation: Short target price = short entry price - (short stop price - short entry price) * reward-to-risk parameter
Long: First overlap since creation of an unmitigated demand zone AND low <= zone top AND high >= zone bottom AND low >= zone bottom AND close > EMA(close, trend-filter lookback)
Short: First overlap since creation of an unmitigated supply zone AND low <= zone top AND high >= zone bottom AND high <= zone top AND close < EMA(close, trend-filter lookback)
Exit: long, high >= long target price OR low <= long stop price
Exit: short, low <= short target price OR high >= short stop price