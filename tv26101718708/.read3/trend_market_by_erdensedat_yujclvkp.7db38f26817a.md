Calculation: pivot high level = latest non-na PivotHigh(high, structure span, structure span)
Calculation: pivot low level = latest non-na PivotLow(low, structure span, structure span)
Calculation: structure high = PivotHigh(high, structure span, structure span) if not na, else structure high[1] unless close[1] > structure high[1]
Calculation: structure low = PivotLow(low, structure span, structure span) if not na, else structure low[1] unless close[1] < structure low[1]
Calculation: structure direction = -1 if close < structure low, 1 if close > structure high, else structure direction[1]
Calculation: long stop = pivot low level if close > structure high AND structure direction[1] != 1, else long stop[1]
Calculation: short stop = pivot high level if close < structure low AND structure direction[1] != -1, else short stop[1]
Calculation: take-profit multiple(k) = (k - 1) / 2 + fibonacci ratio if k is odd, else k / 2
Long: close > structure high
Short: close < structure low
Long: PivotLow(low, ghost span, ghost span) is not na AND structure direction = 1
Short: PivotHigh(high, ghost span, ghost span) is not na AND structure direction = -1
Long: low > high[2] AND close[1] > open[1]
Short: high < low[2] AND close[1] < open[1]
Exit: long, low <= long stop
Exit: short, high >= short stop
Exit: long, highest high since entry crosses above entry price + (entry price - pivot low level at entry) * take-profit multiple(k) for some k
Exit: short, lowest low since entry crosses below entry price - (pivot high level at entry - entry price) * take-profit multiple(k) for some k