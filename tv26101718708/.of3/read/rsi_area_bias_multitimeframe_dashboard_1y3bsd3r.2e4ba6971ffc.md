Calculation: AreaDifference = area lookback * (SMA(max(RSI(close, RSI lookback) - EMA(RSI(close, RSI lookback), baseline EMA lookback), 0), area lookback) - SMA(max(EMA(RSI(close, RSI lookback), baseline EMA lookback) - RSI(close, RSI lookback), 0), area lookback))
Calculation: NormalizedAreaScore = if Highest(AreaDifference, normalization lookback) = Lowest(AreaDifference, normalization lookback) then 0 else 200 * (AreaDifference - Lowest(AreaDifference, normalization lookback)) / (Highest(AreaDifference, normalization lookback) - Lowest(AreaDifference, normalization lookback)) - 100; calculate on the input timeframe's own bars, using its bar still forming for T1–T4 and chart bars for the plotted score
Calculation: OverallScore = (weight1 * NormalizedAreaScore(T1) + weight2 * NormalizedAreaScore(T2) + weight3 * NormalizedAreaScore(T3) + weight4 * NormalizedAreaScore(T4)) / (weight1 + weight2 + weight3 + weight4), where weight1 < weight2 < weight3 < weight4
Long: NormalizedAreaScore(T1) > 0
Long: NormalizedAreaScore(T2) > 0
Long: NormalizedAreaScore(T3) > 0
Long: NormalizedAreaScore(T4) > 0
Long: OverallScore > 0
Long: NormalizedAreaScore(close on chart bars) >= EMA(NormalizedAreaScore(close on chart bars), score MA lookback)
Short: NormalizedAreaScore(T1) < 0
Short: NormalizedAreaScore(T2) < 0
Short: NormalizedAreaScore(T3) < 0
Short: NormalizedAreaScore(T4) < 0
Short: OverallScore < 0
Short: NormalizedAreaScore(close on chart bars) < EMA(NormalizedAreaScore(close on chart bars), score MA lookback)