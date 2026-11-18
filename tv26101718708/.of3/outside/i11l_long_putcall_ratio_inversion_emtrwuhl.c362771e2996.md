Calculation: put-call options ratio SMA = SMA(put-call options ratio close on T1, P1)
Calculation: put-call options ratio baseline = SMA(put-call options ratio SMA, P2)
Calculation: put-call options ratio standard deviation = Standard deviation(put-call options ratio SMA, P2)
Calculation: upper deviation = put-call options ratio baseline + P3 × put-call options ratio standard deviation
Calculation: lower deviation = put-call options ratio baseline − P3 × put-call options ratio standard deviation
Long: Crossunder(put-call options ratio SMA, upper deviation)
Short: Crossover(put-call options ratio SMA, lower deviation)
Exit: short, put-call options ratio SMA > put-call options ratio baseline