Calculation: log-price oscillator = if STDEV(ln(T1 close), lookback) = 0 then 0 else (ln(T1 close) − SMA(ln(T1 close), lookback)) / STDEV(ln(T1 close), lookback); SMA and STDEV run on chart bars taking close from T1’s still-forming bar
Long: log-price oscillator crosses above the negative standard-deviation threshold
Short: log-price oscillator crosses below the positive standard-deviation threshold
Calculation: logarithmic price oscillator = (ln(Bitcoin USD close on T1) - SMA(ln(Bitcoin USD close on T1), length)) / StDev(ln(Bitcoin USD close on T1), length)
Short: previous logarithmic price oscillator >= upper deviation threshold AND current logarithmic price oscillator < upper deviation threshold
Long: previous logarithmic price oscillator <= lower deviation threshold AND current logarithmic price oscillator > lower deviation threshold