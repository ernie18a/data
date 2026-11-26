Long: RSI(close, RSI lookback) > upper threshold AND abs(close - close[2]) > ATR(ATR lookback) / range divisor
Short: RSI(close, RSI lookback) < lower threshold AND abs(close - close[2]) > ATR(ATR lookback) / range divisor
Long: On chart bars using values from the T1 bar still forming, RSI(close, RSI lookback, T1) > upper threshold AND abs(close - close[2], T1) > ATR(ATR lookback, T1) / range divisor
Short: On chart bars using values from the T1 bar still forming, RSI(close, RSI lookback, T1) < lower threshold AND abs(close - close[2], T1) > ATR(ATR lookback, T1) / range divisor