Calculation: Price movement = close - open, or close - close[1] when close = open (on T1 bars, including the bar still forming)
Calculation: Open interest change = change(Open interest, 1) (on T1 bars, including the bar still forming)
Long: Price movement > 0 AND Open interest change > 0
Short: Price movement < 0 AND Open interest change > 0
Exit: long, Price movement < 0 AND Open interest change < 0
Exit: short, Price movement > 0 AND Open interest change < 0