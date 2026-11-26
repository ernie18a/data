Calculation: Move = close - close(T2, last completed bar, chart bars)
Calculation: Scaled = abs(Move) * sensitivity
Long: close >= open(T1, forming bar, chart bars)
Short: close < open(T1, forming bar, chart bars)
Long: Move >= 0
Short: Move < 0
Long: Move >= 0 AND Scaled >= stop threshold
Short: Move < 0 AND Scaled >= stop threshold
Long: close >= close[1]
Short: close < close[1]