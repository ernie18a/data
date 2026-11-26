Calculation: ATR-normalized anchor slope(X) = (SMA(source, anchor lookback, X) - SMA(source, anchor lookback, X)[slope lookback]) / slope lookback / ATR(ATR lookback, X), calculated on X bars.
Long: ATR-normalized anchor slope(Ti) > flat threshold, for each T1 through T10, read on chart bars using lookahead-off values (last completed Ti bar historically; still-forming Ti bar in realtime).
Short: ATR-normalized anchor slope(Ti) < -flat threshold, for each T1 through T10, read on chart bars using lookahead-off values (last completed Ti bar historically; still-forming Ti bar in realtime).
Long: on chart bars, ATR-normalized anchor slope(chart) > 0 AND abs(ATR-normalized anchor slope(chart)) >= flat threshold.
Short: on chart bars, ATR-normalized anchor slope(chart) <= 0 AND abs(ATR-normalized anchor slope(chart)) >= flat threshold.
Long: the number of T1–T5 slopes above the flat threshold is a strict majority of the five scalp timeframes.
Short: the number of T1–T5 slopes below the negative flat threshold is a strict majority of the five scalp timeframes.
Long: ATR-normalized anchor slope(T1) through ATR-normalized anchor slope(T5) are all above the flat threshold.
Short: ATR-normalized anchor slope(T1) through ATR-normalized anchor slope(T5) are all below the negative flat threshold.
Long: ATR-normalized anchor slope(T6) through ATR-normalized anchor slope(T10) are all above the flat threshold.
Short: ATR-normalized anchor slope(T6) through ATR-normalized anchor slope(T10) are all below the negative flat threshold.
Long: ATR-normalized anchor slope(T1) through ATR-normalized anchor slope(T10) are all above the flat threshold.
Short: ATR-normalized anchor slope(T1) through ATR-normalized anchor slope(T10) are all below the negative flat threshold.