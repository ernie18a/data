Calculation: trend state on T1 bars = up when close > upper band, down when close < lower band, otherwise the previous trend state; upper band = highest high over lookback − (highest high − lowest low over lookback) × threshold percentage / 100; lower band = lowest low over lookback + (highest high − lowest low over lookback) × threshold percentage / 100; threshold percentage = base parameter − risk parameter
Calculation: trend change = current trend state differs from previous trend state
Long: long-entry permission enabled AND trend change is up on the last completed T1 bar
Short: short-entry permission enabled AND trend change is down on the last completed T1 bar
Exit: long, long-exit permission enabled AND trend state is down on the last completed T1 bar
Exit: short, short-exit permission enabled AND trend state is up on the last completed T1 bar