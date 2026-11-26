Calculation: RSI_T = RSI(close, RSI lookback) on T bars, bar still forming, returned to chart bars; T ∈ {T1, T2, T3, T4, T5}
Calculation: RSI_MA_T = SMA(RSI(close, RSI lookback), RSI MA lookback) on T bars, bar still forming, returned to chart bars; T ∈ {T1, T2, T3, T4, T5}
Long: for any T ∈ {T1, T2, T3, T4, T5}, RSI_T > upper RSI threshold OR RSI_T > RSI_MA_T
Short: for any T ∈ {T1, T2, T3, T4, T5}, RSI_T < lower RSI threshold OR RSI_T <= RSI_MA_T