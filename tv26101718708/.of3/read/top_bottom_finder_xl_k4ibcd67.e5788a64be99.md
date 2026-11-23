Calculation: BarSpan = high - low
Calculation: TopPivotDefined = PivotHigh(high, L, R, T1, last completed bar) is not NA
Calculation: TopConfirmed = TopPivotDefined AND PivotHigh(high, L, R, T1, last completed bar) > EMA(close, E, T1, last completed bar)[R] + ATR(A, T1, last completed bar)[R] * M AND volume[R] >= SMA(volume, V, T1, last completed bar)[R] * VM AND BarSpan[R] >= SMA(BarSpan, V, T1, last completed bar)[R] * RM AND RSI(close, Q, T1, last completed bar)[R] >= TW
Calculation: BottomPivotDefined = PivotLow(low, L, R, T1, last completed bar) is not NA
Calculation: BottomConfirmed = BottomPivotDefined AND PivotLow(low, L, R, T1, last completed bar) < EMA(close, E, T1, last completed bar)[R] - ATR(A, T1, last completed bar)[R] * M AND volume[R] >= SMA(volume, V, T1, last completed bar)[R] * VM AND BarSpan[R] >= SMA(BarSpan, V, T1, last completed bar)[R] * RM AND RSI(close, Q, T1, last completed bar)[R] <= BW
Short: TopPivotDefined AND NOT TopPivotDefined[1]
Short: TopConfirmed AND NOT TopConfirmed[1]
Short: TopConfirmed AND RSI(close, Q, T1, last completed bar)[R] < TS AND NOT TopConfirmed[1]
Short: TopConfirmed AND RSI(close, Q, T1, last completed bar)[R] >= TS AND RSI(close, Q, T1, last completed bar)[R] < TE AND NOT TopConfirmed[1]
Short: TopConfirmed AND RSI(close, Q, T1, last completed bar)[R] >= TE AND NOT TopConfirmed[1]
Long: BottomPivotDefined AND NOT BottomPivotDefined[1]
Long: BottomConfirmed AND NOT BottomConfirmed[1]
Long: BottomConfirmed AND RSI(close, Q, T1, last completed bar)[R] > BS AND NOT BottomConfirmed[1]
Long: BottomConfirmed AND RSI(close, Q, T1, last completed bar)[R] <= BS AND RSI(close, Q, T1, last completed bar)[R] > BE AND NOT BottomConfirmed[1]
Long: BottomConfirmed AND RSI(close, Q, T1, last completed bar)[R] <= BE AND NOT BottomConfirmed[1]