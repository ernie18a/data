Calculation: Prior T1 high = high of the last completed T1 bar, carried onto chart bars
Calculation: Prior T1 low = low of the last completed T1 bar, carried onto chart bars
Calculation: VWAP percentage change = 100 * (VWAP((high + low + close) / 3) - VWAP((high + low + close) / 3)[slope lookback]) / VWAP((high + low + close) / 3)[slope lookback]
Long: close > Prior T1 high AND close[1] <= Prior T1 high
Long: close > Prior T1 low AND close[1] <= Prior T1 low
Long: close > Prior T1 high AND VWAP percentage change > slope threshold AND close > VWAP((high + low + close) / 3)
Long: each of the previous setup lookback bars has close below VWAP((high + low + close) / 3) AND close > VWAP((high + low + close) / 3) AND close > open AND close < Prior T1 high
Short: high >= Prior T1 high AND close < Prior T1 high AND high[1] < Prior T1 high
Short: close < Prior T1 low AND close[1] >= Prior T1 low
Short: close < Prior T1 high AND close[1] > Prior T1 high AND some bar in the preceding sweep lookback bars had close > Prior T1 high AND its previous close <= Prior T1 high
Short: close < Prior T1 low AND VWAP percentage change < -slope threshold AND close < VWAP((high + low + close) / 3)
Short: each of the previous setup lookback bars has close above VWAP((high + low + close) / 3) AND close < VWAP((high + low + close) / 3) AND close < open AND close > Prior T1 low
Exit: long, close > Prior T1 high AND VWAP percentage change <= slope threshold