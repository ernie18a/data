Calculation: macd_line(Tx) = EMA(close, fast MACD lookback, Tx, last completed bar) - EMA(close, slow MACD lookback, Tx, last completed bar)
Calculation: macd_signal(Tx) = EMA(macd_line, MACD signal lookback, Tx, last completed bar)
Calculation: trend_state(Tx) = 1 if EMA(close, longer lookback, Tx, last completed bar) > EMA(close, longest lookback, Tx, last completed bar) AND MFI(hlc3, MFI lookback, Tx, last completed bar) > MFI bullish threshold AND RSI(close, RSI lookback, Tx, last completed bar) > RSI bullish threshold AND ADX(DI lookback, ADX smoothing lookback, Tx, last completed bar) > ADX minimum threshold AND macd_line(Tx) > macd_signal(Tx) AND close(Tx, last completed bar) > VWAP(hlc3, anchor period, Tx, last completed bar) AND (EMA(close, shortest lookback, Tx, last completed bar) crosses above EMA(close, shorter lookback, Tx, last completed bar) OR EMA(close, shortest lookback, Tx, last completed bar) crosses above EMA(close, longer lookback, Tx, last completed bar) OR (EMA(close, shortest lookback, Tx, last completed bar) > EMA(close, shorter lookback, Tx, last completed bar) AND EMA(close, shortest lookback, Tx, last completed bar) > EMA(close, longer lookback, Tx, last completed bar))), -1 if EMA(close, longer lookback, Tx, last completed bar) < EMA(close, longest lookback, Tx, last completed bar) AND MFI(hlc3, MFI lookback, Tx, last completed bar) < MFI bearish threshold AND RSI(close, RSI lookback, Tx, last completed bar) < RSI bearish threshold AND ADX(DI lookback, ADX smoothing lookback, Tx, last completed bar) > ADX minimum threshold AND macd_line(Tx) < macd_signal(Tx) AND close(Tx, last completed bar) < VWAP(hlc3, anchor period, Tx, last completed bar) AND (EMA(close, shortest lookback, Tx, last completed bar) crosses below EMA(close, shorter lookback, Tx, last completed bar) OR EMA(close, shortest lookback, Tx, last completed bar) crosses below EMA(close, longer lookback, Tx, last completed bar) OR (EMA(close, shortest lookback, Tx, last completed bar) < EMA(close, shorter lookback, Tx, last completed bar) AND EMA(close, shortest lookback, Tx, last completed bar) < EMA(close, longer lookback, Tx, last completed bar))), otherwise 0
Calculation: consensus_score = trend_state(T3) + trend_state(T4) + trend_state(T5) + trend_state(T6) + trend_state(T7) + trend_state(T8) + trend_state(T9)
Long: consensus_score >= consensus threshold
Short: consensus_score <= -consensus threshold
Long: trend_state(T1) > 0
Short: trend_state(T1) < 0
Long: RSI(close, RSI lookback, T1, last completed bar) >= RSI bullish threshold
Short: RSI(close, RSI lookback, T1, last completed bar) <= RSI bearish threshold
Long: MFI(hlc3, MFI lookback, T1, last completed bar) >= MFI bullish threshold
Short: MFI(hlc3, MFI lookback, T1, last completed bar) <= MFI bearish threshold
Long: close(T1, last completed bar) > VWAP(hlc3, anchor period, T1, last completed bar)
Short: close(T1, last completed bar) <= VWAP(hlc3, anchor period, T1, last completed bar)
Long: (macd_line(T1) < 0 AND macd_line(T1) > macd_signal(T1)) OR (macd_line(T1) >= 0 AND macd_line(T1) >= macd_signal(T1))
Short: (macd_line(T1) < 0 AND macd_line(T1) <= macd_signal(T1)) OR (macd_line(T1) >= 0 AND macd_line(T1) < macd_signal(T1))
Long: trend_state(T2) > 0
Short: trend_state(T2) < 0
Long: RSI(close, RSI lookback, T2, last completed bar) >= RSI bullish threshold
Short: RSI(close, RSI lookback, T2, last completed bar) <= RSI bearish threshold
Long: MFI(hlc3, MFI lookback, T2, last completed bar) >= MFI bullish threshold
Short: MFI(hlc3, MFI lookback, T2, last completed bar) <= MFI bearish threshold
Long: close(T2, last completed bar) > VWAP(hlc3, anchor period, T2, last completed bar)
Short: close(T2, last completed bar) <= VWAP(hlc3, anchor period, T2, last completed bar)
Long: (macd_line(T2) < 0 AND macd_line(T2) > macd_signal(T2)) OR (macd_line(T2) >= 0 AND macd_line(T2) >= macd_signal(T2))
Short: (macd_line(T2) < 0 AND macd_line(T2) <= macd_signal(T2)) OR (macd_line(T2) >= 0 AND macd_line(T2) < macd_signal(T2))
Long: trend_state(T3) > 0
Short: trend_state(T3) < 0
Long: RSI(close, RSI lookback, T3, last completed bar) >= RSI bullish threshold
Short: RSI(close, RSI lookback, T3, last completed bar) <= RSI bearish threshold
Long: MFI(hlc3, MFI lookback, T3, last completed bar) >= MFI bullish threshold
Short: MFI(hlc3, MFI lookback, T3, last completed bar) <= MFI bearish threshold
Long: close(T3, last completed bar) > VWAP(hlc3, anchor period, T3, last completed bar)
Short: close(T3, last completed bar) <= VWAP(hlc3, anchor period, T3, last completed bar)
Long: (macd_line(T3) < 0 AND macd_line(T3) > macd_signal(T3)) OR (macd_line(T3) >= 0 AND macd_line(T3) >= macd_signal(T3))
Short: (macd_line(T3) < 0 AND macd_line(T3) <= macd_signal(T3)) OR (macd_line(T3) >= 0 AND macd_line(T3) < macd_signal(T3))
Long: trend_state(T4) > 0
Short: trend_state(T4) < 0
Long: RSI(close, RSI lookback, T4, last completed bar) >= RSI bullish threshold
Short: RSI(close, RSI lookback, T4, last completed bar) <= RSI bearish threshold
Long: MFI(hlc3, MFI lookback, T4, last completed bar) >= MFI bullish threshold
Short: MFI(hlc3, MFI lookback, T4, last completed bar) <= MFI bearish threshold
Long: close(T4, last completed bar) > VWAP(hlc3, anchor period, T4, last completed bar)
Short: close(T4, last completed bar) <= VWAP(hlc3, anchor period, T4, last completed bar)
Long: (macd_line(T4) < 0 AND macd_line(T4) > macd_signal(T4)) OR (macd_line(T4) >= 0 AND macd_line(T4) >= macd_signal(T4))
Short: (macd_line(T4) < 0 AND macd_line(T4) <= macd_signal(T4)) OR (macd_line(T4) >= 0 AND macd_line(T4) < macd_signal(T4))
Long: trend_state(T5) > 0
Short: trend_state(T5) < 0
Long: RSI(close, RSI lookback, T5, last completed bar) >= RSI bullish threshold
Short: RSI(close, RSI lookback, T5, last completed bar) <= RSI bearish threshold
Long: MFI(hlc3, MFI lookback, T5, last completed bar) >= MFI bullish threshold
Short: MFI(hlc3, MFI lookback, T5, last completed bar) <= MFI bearish threshold
Long: close(T5, last completed bar) > VWAP(hlc3, anchor period, T5, last completed bar)
Short: close(T5, last completed bar) <= VWAP(hlc3, anchor period, T5, last completed bar)
Long: (macd_line(T5) < 0 AND macd_line(T5) > macd_signal(T5)) OR (macd_line(T5) >= 0 AND macd_line(T5) >= macd_signal(T5))
Short: (macd_line(T5) < 0 AND macd_line(T5) <= macd_signal(T5)) OR (macd_line(T5) >= 0 AND macd_line(T5) < macd_signal(T5))
Long: trend_state(T6) > 0
Short: trend_state(T6) < 0
Long: RSI(close, RSI lookback, T6, last completed bar) >= RSI bullish threshold
Short: RSI(close, RSI lookback, T6, last completed bar) <= RSI bearish threshold
Long: MFI(hlc3, MFI lookback, T6, last completed bar) >= MFI bullish threshold
Short: MFI(hlc3, MFI lookback, T6, last completed bar) <= MFI bearish threshold
Long: close(T6, last completed bar) > VWAP(hlc3, anchor period, T6, last completed bar)
Short: close(T6, last completed bar) <= VWAP(hlc3, anchor period, T6, last completed bar)
Long: (macd_line(T6) < 0 AND macd_line(T6) > macd_signal(T6)) OR (macd_line(T6) >= 0 AND macd_line(T6) >= macd_signal(T6))
Short: (macd_line(T6) < 0 AND macd_line(T6) <= macd_signal(T6)) OR (macd_line(T6) >= 0 AND macd_line(T6) < macd_signal(T6))
Long: trend_state(T7) > 0
Short: trend_state(T7) < 0
Long: RSI(close, RSI lookback, T7, last completed bar) >= RSI bullish threshold
Short: RSI(close, RSI lookback, T7, last completed bar) <= RSI bearish threshold
Long: MFI(hlc3, MFI lookback, T7, last completed bar) >= MFI bullish threshold
Short: MFI(hlc3, MFI lookback, T7, last completed bar) <= MFI bearish threshold
Long: close(T7, last completed bar) > VWAP(hlc3, anchor period, T7, last completed bar)
Short: close(T7, last completed bar) <= VWAP(hlc3, anchor period, T7, last completed bar)
Long: (macd_line(T7) < 0 AND macd_line(T7) > macd_signal(T7)) OR (macd_line(T7) >= 0 AND macd_line(T7) >= macd_signal(T7))
Short: (macd_line(T7) < 0 AND macd_line(T7) <= macd_signal(T7)) OR (macd_line(T7) >= 0 AND macd_line(T7) < macd_signal(T7))
Long: trend_state(T8) > 0
Short: trend_state(T8) < 0
Long: RSI(close, RSI lookback, T8, last completed bar) >= RSI bullish threshold
Short: RSI(close, RSI lookback, T8, last completed bar) <= RSI bearish threshold
Long: MFI(hlc3, MFI lookback, T8, last completed bar) >= MFI bullish threshold
Short: MFI(hlc3, MFI lookback, T8, last completed bar) <= MFI bearish threshold
Long: close(T8, last completed bar) > VWAP(hlc3, anchor period, T8, last completed bar)
Short: close(T8, last completed bar) <= VWAP(hlc3, anchor period, T8, last completed bar)
Long: (macd_line(T8) < 0 AND macd_line(T8) > macd_signal(T8)) OR (macd_line(T8) >= 0 AND macd_line(T8) >= macd_signal(T8))
Short: (macd_line(T8) < 0 AND macd_line(T8) <= macd_signal(T8)) OR (macd_line(T8) >= 0 AND macd_line(T8) < macd_signal(T8))
Long: trend_state(T9) > 0
Short: trend_state(T9) < 0
Long: RSI(close, RSI lookback, T9, last completed bar) >= RSI bullish threshold
Short: RSI(close, RSI lookback, T9, last completed bar) <= RSI bearish threshold
Long: MFI(hlc3, MFI lookback, T9, last completed bar) >= MFI bullish threshold
Short: MFI(hlc3, MFI lookback, T9, last completed bar) <= MFI bearish threshold
Long: close(T9, last completed bar) > VWAP(hlc3, anchor period, T9, last completed bar)
Short: close(T9, last completed bar) <= VWAP(hlc3, anchor period, T9, last completed bar)
Long: (macd_line(T9) < 0 AND macd_line(T9) > macd_signal(T9)) OR (macd_line(T9) >= 0 AND macd_line(T9) >= macd_signal(T9))
Short: (macd_line(T9) < 0 AND macd_line(T9) <= macd_signal(T9)) OR (macd_line(T9) >= 0 AND macd_line(T9) < macd_signal(T9))
Long: trend_state(T10) > 0
Short: trend_state(T10) < 0
Long: RSI(close, RSI lookback, T10, last completed bar) >= RSI bullish threshold
Short: RSI(close, RSI lookback, T10, last completed bar) <= RSI bearish threshold
Long: MFI(hlc3, MFI lookback, T10, last completed bar) >= MFI bullish threshold
Short: MFI(hlc3, MFI lookback, T10, last completed bar) <= MFI bearish threshold
Long: close(T10, last completed bar) > VWAP(hlc3, anchor period, T10, last completed bar)
Short: close(T10, last completed bar) <= VWAP(hlc3, anchor period, T10, last completed bar)
Long: (macd_line(T10) < 0 AND macd_line(T10) > macd_signal(T10)) OR (macd_line(T10) >= 0 AND macd_line(T10) >= macd_signal(T10))
Short: (macd_line(T10) < 0 AND macd_line(T10) <= macd_signal(T10)) OR (macd_line(T10) >= 0 AND macd_line(T10) < macd_signal(T10))
Long: trend_state(T11) > 0
Short: trend_state(T11) < 0
Long: RSI(close, RSI lookback, T11, last completed bar) >= RSI bullish threshold
Short: RSI(close, RSI lookback, T11, last completed bar) <= RSI bearish threshold
Long: MFI(hlc3, MFI lookback, T11, last completed bar) >= MFI bullish threshold
Short: MFI(hlc3, MFI lookback, T11, last completed bar) <= MFI bearish threshold
Long: close(T11, last completed bar) > VWAP(hlc3, anchor period, T11, last completed bar)
Short: close(T11, last completed bar) <= VWAP(hlc3, anchor period, T11, last completed bar)
Long: (macd_line(T11) < 0 AND macd_line(T11) > macd_signal(T11)) OR (macd_line(T11) >= 0 AND macd_line(T11) >= macd_signal(T11))
Short: (macd_line(T11) < 0 AND macd_line(T11) <= macd_signal(T11)) OR (macd_line(T11) >= 0 AND macd_line(T11) < macd_signal(T11))