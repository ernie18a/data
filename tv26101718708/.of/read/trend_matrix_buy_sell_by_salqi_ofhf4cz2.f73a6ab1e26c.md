Calculation: BullCount = number of true tests among 9: close > EMA(close,20), close > EMA(close,50), close > EMA(close,200), each evaluated on three EMA timeframes TF1 < TF2 < TF3 (each may be lower than, equal to, or higher than the chart timeframe; each EMA uses the bar of its timeframe still forming at the current chart bar)
Calculation: BearCount = 9 - BullCount
Calculation: VWAP = session-anchored volume-weighted average of (high+low+close)/3, computed on a VWAP timeframe, using the bar still forming
Calculation: PrevDayClose = close of the previous completed daily bar
Long: (BullCount >= T_bull AND previous bar BullCount < T_bull) AND close > VWAP AND the last signal issued was not Long
Long: (BullCount >= S_bull AND previous bar BullCount < S_bull, where S_bull is stricter than T_bull) AND close > VWAP AND the last signal issued was not Long
Long: (BullCount >= T_bull AND close >= PrevDayClose*(1+p)) AND NOT (previous bar BullCount >= T_bull AND previous bar close >= its PrevDayClose*(1+p)) AND close > VWAP AND the last signal issued was not Long
Short: (BearCount >= T_bear AND previous bar BearCount < T_bear) AND close < VWAP AND the last signal issued was not Short
Short: (BearCount >= S_bear AND previous bar BearCount < S_bear, where S_bear is stricter than T_bear) AND close < VWAP AND the last signal issued was not Short
Short: (BearCount >= T_bear AND close <= PrevDayClose*(1-p)) AND NOT (previous bar BearCount >= T_bear AND previous bar close <= its PrevDayClose*(1-p)) AND close < VWAP AND the last signal issued was not Short
Exit: long, any Short condition above is true
Exit: short, any Long condition above is true