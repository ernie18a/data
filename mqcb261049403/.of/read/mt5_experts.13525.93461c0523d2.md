Calculation: Oscillator = a shorter-period Jurik moving average of (close minus a longer-period Tillson T3 moving average of close), with independent smoothing parameters
Calculation: H[n] = oscillator on the higher timeframe, where H[0] is the last completed higher-timeframe bar and H[n] is n bars before it
Calculation: C[n] = oscillator on the chart timeframe, where C[0] is the current bar and C[n] is n bars before it
Long: H[0] > H[1] AND H[1] < H[2]
Long: C[0] != 0 AND C[0] > C[1]
Short: H[0] < H[1] AND H[1] > H[2]
Short: C[0] != 0 AND C[0] < C[1]
Exit: long, H[0] < H[1]
Exit: short, H[0] > H[1]
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance