Calculation: MA cross = MA(close, shorter lookback, MA type, T1) crosses below MA(close, longer lookback, MA type, T1) on T1 bars, using last completed bar
Calculation: CCI cross = CCI(close, CCI lookback, T2) crosses below CCI threshold on T2 bars, using last completed bar
Calculation: Recent(X) = X is true on the current chart bar or on any of the previous keep-alive chart bars
Long: position is flat AND (date range filter is off OR datetime is between start and end) AND combine mode is AND AND Recent(MA cross) AND Recent(CCI cross) AND (MA cross OR CCI cross)
Long: position is flat AND (date range filter is off OR datetime is between start and end) AND combine mode is OR AND (MA cross OR CCI cross)
Exit: long, low <= entry price * (1 - stop-loss percent)
Exit: long, trailing enabled AND Highest(high, since entry) >= entry price * (1 + activation percent) AND low <= Highest(high, since entry) - entry price * trailing deviation
Exit: long, trailing disabled AND high >= entry price * (1 + activation percent)