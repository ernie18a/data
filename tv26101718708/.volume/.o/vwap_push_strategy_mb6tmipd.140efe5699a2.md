Calculation: VWAP = session cumulative sum(close × volume) / session cumulative volume
Calculation: Long trigger level = high on each bar where close > close[1] > close[2] > close[3], close[4] < VWAP, and close[3] > VWAP; otherwise retain its previous value
Calculation: Short trigger level = low on each bar where close < close[1] < close[2] < close[3], close[4] > VWAP, close[3] < VWAP, and close < VWAP; otherwise retain its previous value
Long: close crosses above Long trigger level AND close > VWAP
Short: close crosses below Short trigger level AND close < VWAP
Exit: long, close crosses below VWAP
Exit: short, close crosses above VWAP