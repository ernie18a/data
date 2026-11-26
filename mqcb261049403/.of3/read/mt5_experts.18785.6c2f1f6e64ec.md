Calculation: Fisher = Fisher Transform(price source, lookback, T1, last completed bar)
Long: On each T1 bar close, Fisher > 0 AND Fisher > HighLevel AND (Fisher[1] <= 0 OR Fisher[1] <= HighLevel)
Short: On each T1 bar close, Fisher < 0 AND Fisher < LowLevel AND (Fisher[1] >= 0 OR Fisher[1] >= LowLevel)
Exit: long, Fisher < 0
Exit: short, Fisher > 0