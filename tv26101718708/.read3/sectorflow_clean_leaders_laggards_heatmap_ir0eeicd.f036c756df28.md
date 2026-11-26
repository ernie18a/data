Calculation: RebasedLevel(x) = close(x, T1, last completed bar) / close(x, T1, last completed bar at the first chart bar at or after RebaseStart)
Calculation: RelPerf(x) = 100 * (RebasedLevel(x) / RebasedLevel(benchmark) - 1) if RelativeMode, else 100 * (RebasedLevel(x) - 1)
Calculation: EligibleCount = number of universe symbols x for which RelPerf(x) is defined
Calculation: RisingCount = number of universe symbols x with ROC(close of x, 1, T1, last completed bar) > 0
Calculation: FallingCount = number of universe symbols x with ROC(close of x, 1, T1, last completed bar) < 0
Calculation: Cutoff = max(MinBreadthCount, ceil(BreadthShare * EligibleCount))
Long: EligibleCount > 0 AND RisingCount >= Cutoff
Short: EligibleCount > 0 AND FallingCount >= Cutoff