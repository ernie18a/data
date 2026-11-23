Calculation: SwingHigh = high[swing strength] if high[swing strength] > high[swing strength + i] AND high[swing strength] > high[swing strength - i] for every i from 1 to swing strength, else na
Calculation: SwingLow = low[swing strength] if low[swing strength] < low[swing strength + i] AND low[swing strength] < low[swing strength - i] for every i from 1 to swing strength, else na
Calculation: LastSwingHigh = SwingHigh if not na, else LastSwingHigh[1]
Calculation: LastSwingLow = SwingLow if not na, else LastSwingLow[1]
Calculation: CloseAbove = close > LastSwingHigh + break buffer * ATR(atr lookback) AND ATR(atr lookback) > 0
Calculation: CloseBelow = close < LastSwingLow - break buffer * ATR(atr lookback) AND ATR(atr lookback) > 0
Calculation: HighReady = (SwingHigh is not na OR HighReady[1]) AND NOT CloseAbove
Calculation: LowReady = (SwingLow is not na OR LowReady[1]) AND NOT CloseBelow
Long: CloseAbove AND (SwingHigh is not na OR HighReady[1])
Short: CloseBelow AND (SwingLow is not na OR LowReady[1]) AND NOT (CloseAbove AND (SwingHigh is not na OR HighReady[1]))