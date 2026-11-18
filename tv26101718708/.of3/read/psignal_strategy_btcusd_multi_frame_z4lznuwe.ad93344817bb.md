Calculation: Normalized change score(N) = erf(if StDev(change(OHLC4), N) > 0 then SMA(change(OHLC4), N) / StDev(change(OHLC4), N) / sqrt(2) else 1), evaluated on the stated source bars
Calculation: Chart signal = SMA(Normalized change score(N_A - 1), N_A - 1) on chart bars
Calculation: T1 signal = SMA(Normalized change score(N_B - 1) evaluated on T1 bars including the current forming bar, N_B - 1) on chart bars
Calculation: T2 signal = SMA(Normalized change score(N_C - 1) evaluated on T2 bars including the current forming bar, N_C - 1) on chart bars
Long: Chart signal < 0 AND Chart signal > Chart signal[1] AND no long position from this signal is open
Long: T1 signal < 0 AND T1 signal > T1 signal[1] AND no long position from this signal is open
Long: T2 signal < 0 AND T2 signal > T2 signal[1] AND no long position from this signal is open
Exit: long, Chart signal > 0 AND Chart signal < Chart signal[1]
Exit: long, T1 signal > 0 AND T1 signal < T1 signal[1]
Exit: long, T2 signal > 0 AND T2 signal < T2 signal[1]