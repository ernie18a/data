Calculation: MA(length) = EMA(close, length) if the moving average is an EMA, SMA(close, length) if it is an SMA
Calculation: EMA_T1(length) = EMA(close, length, T1, last completed bar)
Calculation: MACD_line = MACD line of MACD(close, shorter length, longer length, signal length, T1, last completed bar)
Calculation: MACD_signal = signal line of MACD(close, shorter length, longer length, signal length, T1, last completed bar)
Calculation: SuperTrend_dir = direction of SuperTrend(factor, ATR length, T1, last completed bar)
Calculation: RSI_T1 = RSI(close, RSI length, T1, last completed bar)
Long: at least two enabled MAs with positive length AND MA(shorter length) > MA(longer length) for every pair of those MAs with different lengths
Short: at least two enabled MAs with positive length AND MA(shorter length) < MA(longer length) for every pair of those MAs with different lengths
Long: EMA_T1(L1) > EMA_T1(L2) AND EMA_T1(L2) > EMA_T1(L3) AND EMA_T1(L3) > EMA_T1(L4), where L1 < L2 < L3 < L4
Short: EMA_T1(L1) < EMA_T1(L2) AND EMA_T1(L2) < EMA_T1(L3) AND EMA_T1(L3) < EMA_T1(L4), where L1 < L2 < L3 < L4
Long: MACD_line > MACD_signal
Short: MACD_line <= MACD_signal
Long: SuperTrend_dir < 0
Short: SuperTrend_dir >= 0
Long: RSI_T1 > RSI threshold
Short: RSI_T1 <= RSI threshold