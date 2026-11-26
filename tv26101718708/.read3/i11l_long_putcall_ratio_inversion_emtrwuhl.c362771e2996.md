Calculation: smoothed ratio = SMA(T1 close sampled on chart bars (last completed T1 bar historically; still-forming T1 bar in realtime), ratio lookback)
Calculation: ratio mean = SMA(smoothed ratio, band lookback) on chart bars
Calculation: ratio deviation = STDEV(smoothed ratio, band lookback) on chart bars
Long: smoothed ratio crosses below ratio mean + deviation multiple * ratio deviation
Short: smoothed ratio crosses above ratio mean - deviation multiple * ratio deviation
Exit: short, smoothed ratio > ratio mean
Exit: long, entry price * (1 - stop-loss percentage) > low
Exit: short, entry price * (1 + stop-loss percentage) < high
Exit: long, entry price * (1 + stop-loss percentage * reward-risk multiple) < high
Exit: short, entry price * (1 + stop-loss percentage * reward-risk multiple) < high
Calculation: put-call options ratio SMA = SMA(put-call options ratio close on T1, P1)
Calculation: put-call options ratio baseline = SMA(put-call options ratio SMA, P2)
Calculation: put-call options ratio standard deviation = Standard deviation(put-call options ratio SMA, P2)
Calculation: upper deviation = put-call options ratio baseline + P3 × put-call options ratio standard deviation
Calculation: lower deviation = put-call options ratio baseline − P3 × put-call options ratio standard deviation
Long: Crossunder(put-call options ratio SMA, upper deviation)
Short: Crossover(put-call options ratio SMA, lower deviation)
Exit: short, put-call options ratio SMA > put-call options ratio baseline