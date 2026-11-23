Calculation: bull_gap = low - high[2]
Calculation: bear_gap = low[2] - high
Calculation: bull_formed = bull_gap > 0 AND bull_gap >= ATR(high, low, close, ATR lookback)[1] * min gap multiple
Calculation: bear_formed = bear_gap > 0 AND bear_gap >= ATR(high, low, close, ATR lookback)[1] * min gap multiple
Calculation: bull_top_open = highest low[k] over bars k before the current bar where bull_formed[k] AND low[j] > low[k] for every bar j from k+1 through the previous bar
Calculation: bear_bottom_open = lowest high[k] over bars k before the current bar where bear_formed[k] AND high[j] < high[k] for every bar j from k+1 through the previous bar
Long: bull_formed
Long: bull_formed AND bull_gap >= ATR(high, low, close, ATR lookback)[1] * strong gap multiple AND volume[1] >= SMA(volume, volume lookback)[1] * strong volume multiple AND SMA(volume, volume lookback)[1] > 0
Long: T1 bar starts on this chart bar AND low(T1, last completed bar) > high(T1, last completed bar)[2]
Long: low <= bull_top_open
Short: bear_formed
Short: bear_formed AND bear_gap >= ATR(high, low, close, ATR lookback)[1] * strong gap multiple AND volume[1] >= SMA(volume, volume lookback)[1] * strong volume multiple AND SMA(volume, volume lookback)[1] > 0
Short: T1 bar starts on this chart bar AND high(T1, last completed bar) < low(T1, last completed bar)[2]
Short: high >= bear_bottom_open