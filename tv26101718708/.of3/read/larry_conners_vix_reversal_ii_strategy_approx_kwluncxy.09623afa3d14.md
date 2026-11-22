Long: RSI(close of the requested symbol on T1, bar still forming; RSI lookback), computed on chart bars using T1 values, crosses above the overbought threshold AND holding count = 0
Short: RSI(close of the requested symbol on T1, bar still forming; RSI lookback), computed on chart bars using T1 values, crosses below the oversold threshold AND holding count = 0
Calculation: holding count = 0 while flat, 2 on the entry chart bar, and the prior chart bar's holding count + 1 on each subsequent chart bar while positioned
Exit: long, holding count >= minimum holding period AND holding count <= maximum holding period
Exit: short, holding count >= minimum holding period AND holding count <= maximum holding period
Long: RSI(VIX close on T1, P1) crosses above P2
Short: RSI(VIX close on T1, P1) crosses below P3