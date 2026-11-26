Calculation: AvgGain = RMA(max(close - close[1], 0), RSI lookback)
Calculation: AvgLoss = RMA(max(close[1] - close, 0), RSI lookback)
Calculation: RequiredUpMove(target) = (RSI lookback - 1) * ((target / (100 - target)) * AvgLoss[1] - AvgGain[1])
Calculation: RequiredDownMove(target) = (RSI lookback - 1) * (AvgGain[1] / (target / (100 - target)) - AvgLoss[1])
Calculation: RsiTargetPrice(target) = close[1] + RequiredUpMove(target) if RequiredUpMove(target) > 0, else close[1] - RequiredDownMove(target) if RequiredDownMove(target) > 0, else close[1]
Calculation: LatestPOC = midpoint of the bin with the largest total liquidity, where the latest session's high-low range is cut into bin-count equal bins and each chart bar's liquidity, the sum of T1 liquidity over its most recent sample-cap completed T1 bars (all if sample cap is unset; T1 liquidity = volume, or ABS(close - open), per liquidity source), is spread equally over the bins from its low to its high
Calculation: EntryRisk = stop multiplier * ATR(ATR lookback) at the entry bar
Long: T1 shorter than chart timeframe AND low <= RsiTargetPrice(lower target) AND (NOT wall filter enabled OR ABS(RsiTargetPrice(lower target) - LatestPOC) <= ATR(ATR lookback) * proximity multiplier)
Short: T1 shorter than chart timeframe AND high >= RsiTargetPrice(upper target) AND (NOT wall filter enabled OR ABS(RsiTargetPrice(upper target) - LatestPOC) <= ATR(ATR lookback) * proximity multiplier) AND NOT (low <= RsiTargetPrice(lower target) AND (NOT wall filter enabled OR ABS(RsiTargetPrice(lower target) - LatestPOC) <= ATR(ATR lookback) * proximity multiplier))
Exit: long, low <= entry price - EntryRisk
Exit: long, high >= entry price + EntryRisk * reward-to-risk ratio
Exit: short, high >= entry price + EntryRisk
Exit: short, low <= entry price - EntryRisk * reward-to-risk ratio