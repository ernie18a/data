Calculation: HighSinceEntry = highest high since position entry
Calculation: LowSinceEntry = lowest low since position entry
Calculation: VolIndex = S&P 500 implied volatility index close on T2 bars, last completed bar
Long: PivotLow(low, pivot length, pivot length) is not NA AND position side is flat AND (session filter disabled OR datetime within session window) AND (ATR gate disabled OR ATR(high, low, close, ATR length) > minimum ATR) AND (RSI gate disabled OR RSI(close, RSI length) < long RSI threshold) AND (volatility index gate disabled OR (VolIndex >= minimum volatility index AND VolIndex <= maximum volatility index)) AND (EMA gate disabled OR close > EMA(close, EMA length, T1, last completed bar))
Short: PivotHigh(high, pivot length, pivot length) is not NA AND position side is flat AND (session filter disabled OR datetime within session window) AND (ATR gate disabled OR ATR(high, low, close, ATR length) > minimum ATR) AND (RSI gate disabled OR RSI(close, RSI length) > short RSI threshold) AND (volatility index gate disabled OR (VolIndex >= minimum volatility index AND VolIndex <= maximum volatility index)) AND (EMA gate disabled OR close < EMA(close, EMA length, T1, last completed bar))
Long: RSI(close, RSI length) < long RSI threshold
Short: RSI(close, RSI length) >= long RSI threshold AND RSI(close, RSI length) > short RSI threshold
Long: close > EMA(close, EMA length, T1, last completed bar)
Short: close <= EMA(close, EMA length, T1, last completed bar)
Exit: long, high >= entry price + take-profit distance OR low <= entry price - stop-loss distance OR (HighSinceEntry >= entry price + trail activation distance AND low <= HighSinceEntry - trail offset distance)
Exit: short, low <= entry price - take-profit distance OR high >= entry price + stop-loss distance OR (LowSinceEntry <= entry price - trail activation distance AND high >= LowSinceEntry + trail offset distance)
Exit: long, position side[1] is long AND position side is flat
Exit: short, position side[1] is short AND position side is flat