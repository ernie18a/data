Calculation: T3 = with E1 = EMA(close, L), E2 = EMA(E1, L), …, E6 = EMA(E5, L): −v³E6 + (3v² + 3v³)E5 + (−6v² − 3v − 3v³)E4 + (1 + 3v + v³ + 3v²)E3
Long: close > T3 AND previous close <= previous T3 AND volume > SMA(volume)
Short: close < T3 AND previous close >= previous T3 AND volume > SMA(volume)
Exit: Long, high >= entry price + entry-signal-bar close × (1 + take-profit %) OR low <= entry price − entry-signal-bar close × (1 − stop-loss %) OR close < T3 AND previous close >= previous T3 AND volume > SMA(volume)
Exit: Short, low <= entry price − entry-signal-bar close × (1 − take-profit %) OR high >= entry price + entry-signal-bar close × (1 + stop-loss %) OR close > T3 AND previous close <= previous T3 AND volume > SMA(volume)