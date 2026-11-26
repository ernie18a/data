Calculation: c = CyclePeriod(close, T1, last completed bar), evaluated on T1 bars; c[0] is the latest completed T1 bar
Long: c[0] > c[1] AND c[1] < c[2]
Short: c[0] < c[1] AND c[1] > c[2]
Exit: long, c[1] > c[2] OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, c[1] < c[2] OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance