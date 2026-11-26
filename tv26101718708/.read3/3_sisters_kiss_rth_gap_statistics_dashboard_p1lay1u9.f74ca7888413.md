Calculation: RTH open = open of first bar of latest RTH session
Calculation: prior RTH close = close of last bar of previous RTH session
Calculation: prior RTH high = highest high of bars of previous RTH session
Calculation: prior RTH low = lowest low of bars of previous RTH session
Calculation: gap ratio = ABS(RTH open - prior RTH close) / ATR(T1 bars, atr length)[1] at last completed T1 bar, or n/a if that ATR is not > 0
Long: (RTH open > prior RTH close AND (gap ratio >= upper threshold OR (gap ratio >= middle threshold AND (RTH open > prior RTH high OR RTH open < prior RTH low)))) OR (RTH open < prior RTH close AND (gap ratio < lower threshold OR (gap ratio < middle threshold AND RTH open <= prior RTH high AND RTH open >= prior RTH low)))
Short: (RTH open > prior RTH close AND (gap ratio < lower threshold OR (gap ratio < middle threshold AND RTH open <= prior RTH high AND RTH open >= prior RTH low))) OR (RTH open < prior RTH close AND (gap ratio >= upper threshold OR (gap ratio >= middle threshold AND (RTH open > prior RTH high OR RTH open < prior RTH low))))