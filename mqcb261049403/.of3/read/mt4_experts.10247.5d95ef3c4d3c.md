Calculation: M = SMA(close, MAPeriod, T1 bars, last completed bar)
Long: Monday AND (highest(high, CalcPeriod, T1 bars ending 2 bars ago) < close(T1, last completed bar) OR M > open(T1, bar still forming))
Short: Monday AND (lowest(low, CalcPeriod, T1 bars ending 2 bars ago) > close(T1, last completed bar) OR M < open(T1, bar still forming))
Exit: long, elapsed time since entry > holding-duration parameter
Exit: short, elapsed time since entry > holding-duration parameter