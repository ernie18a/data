Calculation: ZScore(x, n) = 0 if STDEV(x, n) is not positive, otherwise (x - SMA(x, n)) / STDEV(x, n)
Calculation: RocScore = ZScore(ROC(close, rocLength), rocLength)
Calculation: AtrScore = ZScore(ATR(atrLength), atrLength)
Calculation: FlowScore = ZScore(CumSum(volume) - EMA(CumSum(volume), flowLength), flowLength)
Calculation: MacdScore = ZScore(MACD(close, shorterEmaLength, longerEmaLength), longerEmaLength)
Calculation: WeightedScore = (rocWeight * RocScore + atrWeight * AtrScore + flowWeight * FlowScore + macdWeight * MacdScore) / (rocWeight + atrWeight + flowWeight + macdWeight)
Calculation: DominantScore = the one of RocScore, AtrScore, FlowScore and MacdScore with the largest absolute value
Calculation: ScoreSlope = Momentum(EMA(WeightedScore, maLength), 1)
Calculation: PriceChange = ROC(close, divLength)
Calculation: ScoreChange = Momentum(WeightedScore, divLength)
Calculation: DivergenceGap = bars since the last bar where the Long or Short divergence rule was true, infinite if none
Long: ScoreSlope > 0 AND ScoreSlope[1] <= 0
Long: ScoreSlope > 0
Long: WeightedScore > 0
Long: WeightedScore crosses above highThreshold
Long: WeightedScore < lowThreshold
Long: RocScore > 0
Long: AtrScore > 0
Long: FlowScore > 0
Long: MacdScore > 0
Long: DominantScore > 0
Long: PriceChange < -divEpsilon AND ScoreChange > divEpsilon AND DivergenceGap >= divCooldown
Short: ScoreSlope < 0 AND ScoreSlope[1] >= 0
Short: ScoreSlope < 0
Short: WeightedScore < 0
Short: WeightedScore crosses below lowThreshold
Short: WeightedScore > highThreshold
Short: RocScore < 0
Short: AtrScore < 0
Short: FlowScore < 0
Short: MacdScore < 0
Short: DominantScore < 0
Short: PriceChange > divEpsilon AND ScoreChange < -divEpsilon AND DivergenceGap >= divCooldown