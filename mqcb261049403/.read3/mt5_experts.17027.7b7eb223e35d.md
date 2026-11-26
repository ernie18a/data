Calculation: Adaptive lookback = round(base smoothing lookback / (2 * (2 - FDI(applied price, fractal lookback, T1))))
Calculation: DI+ = EMA(if TR > 0 then 100 * +DM / TR else 0, adaptive lookback), calculated on T1 bars and carried to chart bars; [n] indexes chart bars and each carries its corresponding T1 value, forming or completed
Calculation: DI- = EMA(if TR > 0 then 100 * -DM / TR else 0, adaptive lookback), calculated on T1 bars and carried to chart bars; [n] indexes chart bars and each carries its corresponding T1 value, forming or completed
Long: DI+(T1 forming bar) > DI-(T1 forming bar)
Short: DI+(T1 forming bar) < DI-(T1 forming bar)
Long: DI+[N] > DI-[N] AND DI+[N+1] <= DI-[N+1]
Short: DI+[N] < DI-[N] AND DI+[N+1] >= DI-[N+1]
Exit: long, DI+[N] < DI-[N]
Exit: short, DI+[N] > DI-[N]