Calculation: Return(X) = log(X / X[1]) if LogReturns, else X - X[1]
Calculation: Skewness(X) = SMA(D^3, MomentWindow) / SMA(D^2, MomentWindow)^1.5, where D = X - SMA(X, MomentWindow)
Calculation: ExcessKurtosis(X) = SMA(D^4, MomentWindow) / SMA(D^2, MomentWindow)^2 - 3, where D = X - SMA(X, MomentWindow)
Calculation: SkewSeries = Skewness(Return(close)) computed on T1 bars and read at the last completed T1 bar if UseRealized, else Skewness(Return(price source)) computed on chart bars
Calculation: KurtSeries = ExcessKurtosis(Return(close)) computed on T1 bars and read at the last completed T1 bar if UseRealized, else ExcessKurtosis(Return(price source)) computed on chart bars
Calculation: TailPercentile = PercentRank(KurtSeries, TailWindow)
Calculation: SkewScore = if RobustNorm, robust z-score of SkewSeries over SkewWindow (median and median absolute deviation scaled to standard deviation), else z-score of SkewSeries over SkewWindow (mean and standard deviation); if ConsensusNorm, median of these z-scores computed over SkewWindow/2, SkewWindow and 2*SkewWindow
Calculation: SkewIndex = 100 * tanh(SkewScore * SquashScale)
Calculation: VarianceTrend = Correlation(Variance(Return(price source), MomentWindow), bar index, VarWindow)
Long: SkewIndex > ExtremeLevel AND TailPercentile > FatTailPct AND (SkewIndex[1] <= ExtremeLevel OR TailPercentile[1] <= FatTailPct) AND (not VarianceConfirm OR VarianceTrend > VarThreshold)
Short: SkewIndex < -ExtremeLevel AND TailPercentile > FatTailPct AND (SkewIndex[1] >= -ExtremeLevel OR TailPercentile[1] <= FatTailPct) AND (not VarianceConfirm OR VarianceTrend > VarThreshold)
Long: SkewIndex > ExtremeLevel AND TailPercentile > FatTailPct
Short: SkewIndex < -ExtremeLevel AND TailPercentile > FatTailPct
Long: TailPercentile > FatTailPct AND SkewIndex >= 0
Short: TailPercentile > FatTailPct AND SkewIndex < 0