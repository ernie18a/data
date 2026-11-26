Calculation: V = VWAP(close, volume, T1), with V[0] the value on the last completed T1 bar and V[n] the value n T1 bars earlier
Long: V[0] > V[1] AND V[1] < V[2] AND long entries enabled
Short: V[0] < V[1] AND V[1] > V[2] AND short entries enabled
Exit: short, V[0] > V[1] AND V[1] < V[2] AND short exits enabled AND long entries disabled
Exit: long, V[0] < V[1] AND V[1] > V[2] AND long exits enabled AND short entries disabled