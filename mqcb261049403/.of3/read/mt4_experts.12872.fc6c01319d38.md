Calculation: grid distance = (if adaptive spacing is enabled, clamp(round((highest high over the lookback preceding completed chart bars − lowest low over those bars) / (divisor × point)), round(base spacing / divisor), round(base spacing × divisor)); otherwise 0) × point
Calculation: position average entry price = sum(open price × lot size) / sum(lot size)
Long: (flat AND close[2] <= close[1] AND RSI(close, lookback, T1, last completed bar) on chart bars < upper RSI threshold) OR (long position AND last long entry price − Ask >= grid distance)
Short: (flat AND close[2] > close[1] AND RSI(close, lookback, T1, last completed bar) on chart bars > lower RSI threshold) OR (short position AND Bid − last short entry price >= grid distance)
Exit: Long, Bid >= position average entry price + take-profit distance
Exit: Short, Ask <= position average entry price − take-profit distance
Exit: Long, CCI(typical price, lookback, T2, forming bar) on chart bars < −threshold
Exit: Short, CCI(typical price, lookback, T2, forming bar) on chart bars > threshold
Calculation: per-order long trailing stop = when trailing is enabled and round((Bid − position average entry price) / point) >= activation distance, Bid − trail distance if the prior stop is zero, otherwise max(prior stop, Bid − trail distance); otherwise prior stop
Calculation: per-order short trailing stop = when trailing is enabled and round((position average entry price − Ask) / point) >= activation distance, Ask + trail distance if the prior stop is zero, otherwise min(prior stop, Ask + trail distance); otherwise prior stop
Exit: Long, trailing is enabled AND Bid <= per-order long trailing stop
Exit: Short, trailing is enabled AND Ask >= per-order short trailing stop