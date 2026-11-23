Calculation: StochK(T, n) = SMA(Stochastic(close, high, low, StochLength), StochSmoothing) computed on T bars and read on chart bars, where n = 1 is the last completed T bar and n = 2 the one before it
Calculation: StochD(T) = mean of StochK(T, m) for m = 1 to SignalSmoothing, read at the last completed T bar
Calculation: Delta(T) = (StochK(T, 1) - StochK(T, 2)) / FullTurnSlope
Calculation: WeightedMean(x) = (W1*x(T1) + W2*x(T2) + W3*x(T3)) / (W1 + W2 + W3), where x is an expression in T evaluated at T1 < T2 < T3, and a condition counts as 1 when true and 0 when false
Calculation: MeanK = WeightedMean(StochK(T, 1))
Calculation: Agreement = 1 - clamp(sqrt(WeightedMean((StochK(T, 1) - MeanK)^2)) / 50, 0, 1)
Calculation: LongDepth = WeightedMean(clamp((OversoldLevel + SoftWidth - StochK(T, 1)) / SoftWidth, 0, 1))
Calculation: ShortDepth = WeightedMean(clamp((StochK(T, 1) - (OverboughtLevel - SoftWidth)) / SoftWidth, 0, 1))
Calculation: LongDelta = WeightedMean(clamp(Delta(T), 0, 1))
Calculation: ShortDelta = WeightedMean(clamp(-Delta(T), 0, 1))
Calculation: LongCross = WeightedMean(StochK(T, 1) > StochD(T))
Calculation: ShortCross = WeightedMean(StochK(T, 1) < StochD(T))
Calculation: LongScore = 100 * LongDepth * (BaseWeight + CoherenceWeight * Agreement + TurnWeight * LongDelta + CrossWeight * LongCross)
Calculation: ShortScore = 100 * ShortDepth * (BaseWeight + CoherenceWeight * Agreement + TurnWeight * ShortDelta + CrossWeight * ShortCross)
Calculation: LongArmed = BarsSince(StochK(T, 1) <= OversoldLevel) <= ClusterWindow for every T, joined with AND, where BarsSince counts chart bars back to the latest bar on which its condition held, 0 for the current bar
Calculation: ShortArmed = BarsSince(StochK(T, 1) >= OverboughtLevel) <= ClusterWindow for every T, joined with AND, where BarsSince counts chart bars back to the latest bar on which its condition held, 0 for the current bar
Calculation: LongLatch = LongArmed AND MeanK <= LongResetLevel AND (LongLatch[1] OR (LongArmed[1] AND (count of T with Delta(T)[1] > 0) >= MinTurning AND LongScore[1] >= ScoreThreshold))
Calculation: ShortLatch = ShortArmed AND MeanK >= ShortResetLevel AND (ShortLatch[1] OR (ShortArmed[1] AND (count of T with Delta(T)[1] < 0) >= MinTurning AND ShortScore[1] >= ScoreThreshold))
Long: LongArmed AND (count of T with Delta(T) > 0) >= MinTurning AND LongScore >= ScoreThreshold AND NOT LongLatch
Short: ShortArmed AND (count of T with Delta(T) < 0) >= MinTurning AND ShortScore >= ScoreThreshold AND NOT ShortLatch
Long: StochK(T1, 1) <= OversoldLevel AND StochK(T2, 1) <= OversoldLevel AND StochK(T3, 1) <= OversoldLevel
Short: StochK(T1, 1) >= OverboughtLevel AND StochK(T2, 1) >= OverboughtLevel AND StochK(T3, 1) >= OverboughtLevel