Calculation: RangeNormalizedMove = ABS(close - close[1]) / (ATR(atr lookback) + epsilon)
Calculation: SessionHigh(window) = highest high over bars in the current occurrence of window
Calculation: SessionLow(window) = lowest low over bars in the current occurrence of window
Calculation: SessionOpen(window) = open of the first bar in the current occurrence of window
Calculation: SessionClose(window) = close of the latest bar in the current occurrence of window
Long: PivotHigh(high, structure lookback, structure lookback) exists AND PivotLow(low, structure lookback, structure lookback) exists
Short: PivotHigh(high, structure lookback, structure lookback) exists AND PivotLow(low, structure lookback, structure lookback) does not exist
Long: PivotLow(low, left lookback, right lookback) exists
Short: PivotHigh(high, left lookback, right lookback) exists
Long: RangeNormalizedMove > impulse threshold AND close > close[1]
Short: RangeNormalizedMove > impulse threshold AND close < close[1]
Long: SessionClose(Asia window) > SessionOpen(Asia window)
Short: SessionClose(Asia window) < SessionOpen(Asia window)
Long: close > SessionHigh(Asia window)
Short: close < SessionLow(Asia window)
Long: SessionClose(Europe window) > SessionOpen(Europe window)
Short: SessionClose(Europe window) < SessionOpen(Europe window)
Long: close > SessionHigh(Europe window)
Short: close < SessionLow(Europe window)
Long: SessionClose(US window) > SessionOpen(US window)
Short: SessionClose(US window) < SessionOpen(US window)
Long: close > SessionHigh(US window)
Short: close < SessionLow(US window)
Long: close(T1, last completed bar) > high(T1, last completed bar)[1]
Long: close(T1, last completed bar) > close(T1, last completed bar)[1] * (1 + momentum band)
Long: close(T1, last completed bar)[1] > open(T1, last completed bar)[1] * (1 + direction band)
Short: close(T1, last completed bar) < low(T1, last completed bar)[1]
Short: close(T1, last completed bar) < close(T1, last completed bar)[1] * (1 - momentum band)
Short: close(T1, last completed bar)[1] < open(T1, last completed bar)[1] * (1 - direction band)
Long: close(T2, last completed bar) > high(T2, last completed bar)[1]
Long: close(T2, last completed bar) > close(T2, last completed bar)[1] * (1 + momentum band)
Long: close(T2, last completed bar)[1] > open(T2, last completed bar)[1] * (1 + direction band)
Short: close(T2, last completed bar) < low(T2, last completed bar)[1]
Short: close(T2, last completed bar) < close(T2, last completed bar)[1] * (1 - momentum band)
Short: close(T2, last completed bar)[1] < open(T2, last completed bar)[1] * (1 - direction band)
Long: close(T3, last completed bar) > high(T3, last completed bar)[1]
Long: close(T3, last completed bar) > close(T3, last completed bar)[1] * (1 + momentum band)
Long: close(T3, last completed bar)[1] > open(T3, last completed bar)[1] * (1 + direction band)
Short: close(T3, last completed bar) < low(T3, last completed bar)[1]
Short: close(T3, last completed bar) < close(T3, last completed bar)[1] * (1 - momentum band)
Short: close(T3, last completed bar)[1] < open(T3, last completed bar)[1] * (1 - direction band)
Long: close(T4, last completed bar) > high(T4, last completed bar)[1]
Long: close(T4, last completed bar) > close(T4, last completed bar)[1] * (1 + momentum band)
Long: close(T4, last completed bar)[1] > open(T4, last completed bar)[1] * (1 + direction band)
Short: close(T4, last completed bar) < low(T4, last completed bar)[1]
Short: close(T4, last completed bar) < close(T4, last completed bar)[1] * (1 - momentum band)
Short: close(T4, last completed bar)[1] < open(T4, last completed bar)[1] * (1 - direction band)
Long: close(T5, last completed bar) > high(T5, last completed bar)[1]
Long: close(T5, last completed bar) > close(T5, last completed bar)[1] * (1 + momentum band)
Long: close(T5, last completed bar)[1] > open(T5, last completed bar)[1] * (1 + direction band)
Short: close(T5, last completed bar) < low(T5, last completed bar)[1]
Short: close(T5, last completed bar) < close(T5, last completed bar)[1] * (1 - momentum band)
Short: close(T5, last completed bar)[1] < open(T5, last completed bar)[1] * (1 - direction band)