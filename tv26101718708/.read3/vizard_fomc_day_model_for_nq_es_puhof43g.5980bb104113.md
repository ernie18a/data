Calculation: MonthPos = (Close - Lowest(Low, chart bars since current T2 bar opened)) / (Highest(High, chart bars since current T2 bar opened) - Lowest(Low, chart bars since current T2 bar opened))
Calculation: MonthOpenDev = (Close - Open(T2, current bar)) / (ADR(T1, P4, last completed bar) * Open(T1, current bar))
Calculation: Frozen(x) = x at the last completed chart bar before statement time if the current bar is on an FOMC day at or after statement time, else x at the current bar
Long: Frozen(MonthPos) >= P1
Short: Frozen(MonthPos) <= P2
Long: Frozen(MonthOpenDev) < -P3