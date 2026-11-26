Long: EMA(close, shorter lookback) crosses above EMA(close, longer lookback)
Short: EMA(close, shorter lookback) crosses below EMA(close, longer lookback)
Long: +DI(DI lookback) > -DI(DI lookback) on chart bars
Short: -DI(DI lookback) > +DI(DI lookback) on chart bars
Long: on chart bars, +DI(DI lookback) > -DI(DI lookback) calculated on T1 bars using the current bar (still forming in realtime, last completed historically)
Short: on chart bars, -DI(DI lookback) > +DI(DI lookback) calculated on T1 bars using the current bar (still forming in realtime, last completed historically)
Long: on chart bars, +DI(DI lookback) > -DI(DI lookback) calculated on T2 bars using the current bar (still forming in realtime, last completed historically)
Short: on chart bars, -DI(DI lookback) > +DI(DI lookback) calculated on T2 bars using the current bar (still forming in realtime, last completed historically)
Long: on chart bars, +DI(DI lookback) > -DI(DI lookback) calculated on T3 bars using the current bar (still forming in realtime, last completed historically)
Short: on chart bars, -DI(DI lookback) > +DI(DI lookback) calculated on T3 bars using the current bar (still forming in realtime, last completed historically)
Long: on chart bars, +DI(DI lookback) > -DI(DI lookback) calculated on T4 bars using the current bar (still forming in realtime, last completed historically)
Short: on chart bars, -DI(DI lookback) > +DI(DI lookback) calculated on T4 bars using the current bar (still forming in realtime, last completed historically)
Exit: long, low <= entry price * (1 - risk percentage / 100)
Exit: short, high >= entry price * (1 + risk percentage / 100)