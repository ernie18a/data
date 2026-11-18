Calculation: T1 DI+ = DMI+(high(T1, last completed bar), low(T1, last completed bar), close(T1, last completed bar), DMI lookback), calculated on chart bars
Calculation: T1 DI- = DMI-(high(T1, last completed bar), low(T1, last completed bar), close(T1, last completed bar), DMI lookback), calculated on chart bars
Calculation: T2 DI+ = DMI+(high(T2, last completed bar), low(T2, last completed bar), close(T2, last completed bar), DMI lookback), calculated on chart bars
Calculation: T2 DI- = DMI-(high(T2, last completed bar), low(T2, last completed bar), close(T2, last completed bar), DMI lookback), calculated on chart bars
Calculation: Long trailing stop = if long then max(previous long trailing stop, low - ATR(ATR lookback) * ATR multiplier) else low - ATR(ATR lookback) * ATR multiplier
Long: T1 DI+ > T1 DI- AND T2 DI+ > T2 DI-
Long: datetime >= backtest start-time parameter AND T1 DI+ > T1 DI- AND T2 DI+ > T2 DI-
Short: T1 DI+ <= T1 DI- OR T2 DI+ <= T2 DI-
Exit: long, low <= long trailing stop