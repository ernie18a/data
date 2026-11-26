Calculation: Trend score = sign(MA(short MA applied-price parameter, shorter MA lookback, short MA-method parameter) - MA(long MA applied-price parameter, longer MA lookback, long MA-method parameter)) + sign(RSI(short RSI applied-price parameter, shorter RSI lookback) - RSI(long RSI applied-price parameter, longer RSI lookback)); calculated on T1 bars, including the still-forming bar (shift 0 is forming; positive shifts are completed)
Long: Trend score > 0
Short: Trend score < 0
Long: Trend score at the configured signal shift on T1 > 0 AND the most recent earlier nonzero Trend score on T1 < 0 AND long-entry permission is enabled
Short: Trend score at the configured signal shift on T1 < 0 AND the most recent earlier nonzero Trend score on T1 > 0 AND short-entry permission is enabled
Exit: short, Trend score at the configured signal shift on T1 > 0 AND short-exit permission is enabled
Exit: long, Trend score at the configured signal shift on T1 < 0 AND long-exit permission is enabled