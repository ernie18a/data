Calculation: Initial balance high and low = the highest high and lowest low of chart bars in the initial balance window; reset at the start of each window, update during it, and retain the final values until the next window.
Calculation: High break state = true after any chart bar during the regular session, after the initial balance window ends, has high > initial balance high; reset at the start of the next initial balance window.
Calculation: Low break state = true after any chart bar during the regular session, after the initial balance window ends, has low < initial balance low; reset at the start of the next initial balance window.
Long: close > initial balance high OR high break state = true
Short: close < initial balance low OR low break state = true