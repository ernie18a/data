Long: on chart bars, using the T1 bar still forming, close > open(T1) AND open(T1) - low(T1) > risk-range parameter AND no open position AND no same-side trade closed for this instrument today AND within the trading window
Short: on chart bars, using the T1 bar still forming, close < open(T1) AND high(T1) - open(T1) > risk-range parameter AND no open position AND no same-side trade closed for this instrument today AND within the trading window
Exit: long, hour(datetime) >= closing-hour parameter minus time offset
Exit: short, hour(datetime) >= closing-hour parameter minus time offset
Exit: long, holding-duration parameter is nonzero AND elapsed time since entry >= holding-duration parameter AND close > entry price
Exit: short, holding-duration parameter is nonzero AND elapsed time since entry >= holding-duration parameter AND close < entry price