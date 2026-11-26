Calculation: f = FatlMacd(close, indicator parameters, T1, last completed bar), evaluated on each T1 bar close
Long: long entry enabled AND f[0] > f[1] AND f[1] < f[2]
Short: short entry enabled AND f[0] < f[1] AND f[1] > f[2]
Exit: long, long exit enabled AND f[0] < f[1]
Exit: short, short exit enabled AND f[0] > f[1]
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance