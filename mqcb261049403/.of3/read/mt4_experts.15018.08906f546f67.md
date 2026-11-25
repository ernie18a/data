Calculation: weighted average entry price = sum(entry price × position size) / sum(position size)
Calculation: long trailing stop = highest price since entry − trail distance after price reaches weighted average entry price + trail-start distance
Calculation: short trailing stop = lowest price since entry + trail distance after price reaches weighted average entry price − trail-start distance
Long: flat AND close[2] > close[1] AND RSI(close, RSI lookback, T1, last completed bar sampled on chart bars) >= upper RSI threshold
Short: flat AND close[2] > close[1] AND RSI(close, RSI lookback, T1, last completed bar sampled on chart bars) < lower RSI threshold
Long: long position AND last long entry price − current ask >= step parameter × point size AND spread <= spread limit AND (hour(datetime) >= session start hour OR hour(datetime) <= session end hour)
Short: short position AND current bid − last short entry price >= step parameter × point size AND spread <= spread limit AND (hour(datetime) >= session start hour OR hour(datetime) <= session end hour)
Exit: long, low <= any long entry price − stop-loss parameter × point size OR high >= weighted average entry price + take-profit parameter × point size OR (trailing stop enabled AND low <= long trailing stop) OR (timeout enabled AND datetime >= expiry time)
Exit: short, high >= any short entry price + stop-loss parameter × point size OR low <= weighted average entry price − take-profit parameter × point size OR (trailing stop enabled AND high >= short trailing stop) OR (timeout enabled AND datetime >= expiry time)