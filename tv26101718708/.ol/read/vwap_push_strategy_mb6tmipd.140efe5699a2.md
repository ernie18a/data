Calculation: VWAP = session cumulative sum(close × volume) / session cumulative volume
Calculation: Push-up high = high of the latest bar where close > close[1] > close[2] > close[3], close[4] < current VWAP, and close[3] > current VWAP; otherwise retain the prior value
Calculation: Push-down low = low of the latest bar where close < close[1] < close[2] < close[3], close[4] > current VWAP, close[3] < current VWAP, and close < current VWAP; otherwise retain the prior value
Long: close > push-up high AND close[1] <= prior-bar push-up high AND close > VWAP
Short: close < push-down low AND close[1] >= prior-bar push-down low AND close < VWAP
Exit: long, close < VWAP AND close[1] >= prior-bar VWAP
Exit: short, close > VWAP AND close[1] <= prior-bar VWAP