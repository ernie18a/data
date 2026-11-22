Calculation: Midline(X) = (EMA(close, shorter lookback, X) + EMA(close, longer lookback, X)) / 2
Calculation: Bull alignment(X) = EMA(close, shorter lookback, X) >= EMA(close, longer lookback, X) AND close(X) >= Midline(X)
Calculation: Bear alignment(X) = EMA(close, shorter lookback, X) <= EMA(close, longer lookback, X) AND close(X) <= Midline(X)
Calculation: Composite = primary trend weight * (EMA(close, shorter lookback, T1, last completed bar) - EMA(close, longer lookback, T1, last completed bar)) / ATR(ATR lookback, T1, last completed bar) + primary signal weight * (EMA(close, shorter lookback, T1, last completed bar) - EMA(close, shortest lookback, T1, last completed bar)) / ATR(ATR lookback, T1, last completed bar) + secondary trend weight * (EMA(close, shorter lookback, T2, last completed bar) - EMA(close, longer lookback, T2, last completed bar)) / ATR(ATR lookback, T2, last completed bar) + secondary signal weight * (EMA(close, shorter lookback, T2, last completed bar) - EMA(close, shortest lookback, T2, last completed bar)) / ATR(ATR lookback, T2, last completed bar) + location weight * (close - Midline(T1, last completed bar)) / ATR(ATR lookback, T1, last completed bar) + local trend weight * (EMA(close, shorter lookback, chart) - EMA(close, longer lookback, chart)) / ATR(ATR lookback, chart) + local location weight * (close - Midline(chart)) / ATR(ATR lookback, chart)
Calculation: Bull confirmation = bar is confirmed AND Composite >= entry threshold AND Bull alignment(T1, last completed bar) AND Bull alignment(T2, last completed bar) AND close >= Midline(chart)
Calculation: Bear confirmation = bar is confirmed AND Composite <= -entry threshold AND Bear alignment(T1, last completed bar) AND Bear alignment(T2, last completed bar) AND close <= Midline(chart)
Long: Bull confirmation
Long: Bull confirmation AND NOT Bull confirmation[1]
Long: Composite >= state threshold
Long: Composite >= strong state threshold
Long: Bull alignment(T1, last completed bar)
Long: Bull alignment(T2, last completed bar)
Long: close >= Midline(T1, last completed bar)
Short: Bear confirmation
Short: Bear confirmation AND NOT Bear confirmation[1]
Short: Composite <= -state threshold
Short: Composite <= -strong state threshold
Short: Bear alignment(T1, last completed bar)
Short: Bear alignment(T2, last completed bar)
Short: close < Midline(T1, last completed bar)
Exit: long, bar is confirmed AND (close < Midline(chart) OR Composite < exit level)
Exit: short, bar is confirmed AND (close > Midline(chart) OR Composite > -exit level)