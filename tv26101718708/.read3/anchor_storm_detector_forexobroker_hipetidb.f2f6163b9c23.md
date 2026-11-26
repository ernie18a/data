Calculation: ATRExpansionRatio = ATR(ATR lookback) / SMA(ATR(ATR lookback), ATR baseline lookback) when the SMA is positive; otherwise ATR ratio fallback
Calculation: UpBreakCount = count of enabled anchor periods T1, T2, and T3 where close > AnchoredVWAP(hlc3, volume, anchor period T) + ATR(ATR lookback) × break margin AND close[1] <= AnchoredVWAP(hlc3, volume, anchor period T)[1] + current ATR(ATR lookback) × break margin; each anchored VWAP accumulates on chart bars from the start of its anchor period
Calculation: DownBreakCount = count of enabled anchor periods T1, T2, and T3 where close < AnchoredVWAP(hlc3, volume, anchor period T) - ATR(ATR lookback) × break margin AND close[1] >= AnchoredVWAP(hlc3, volume, anchor period T)[1] - current ATR(ATR lookback) × break margin; each anchored VWAP accumulates on chart bars from the start of its anchor period
Calculation: AnchorPositionSum = sum over enabled anchor periods T1, T2, and T3 of +1 when close > AnchoredVWAP(hlc3, volume, anchor period T), -1 when close < it, and 0 when equal
Calculation: StormScore = round(min(total score cap, break score weight × max(UpBreakCount, DownBreakCount) + min(max(ATRExpansionRatio - ATR score baseline ratio, 0) × ATR score weight, ATR score cap) + (enabled anchor count > 0 ? min(abs(AnchorPositionSum) / enabled anchor count × anchor alignment weight, anchor alignment cap) : 0)))
Calculation: BullBias = UpBreakCount >= minimum break count AND ATRExpansionRatio > ATR expansion threshold AND close > EMA(close, bias EMA lookback) AND EMA(close, bias EMA lookback) - EMA(close, bias EMA lookback)[bias slope lookback] > 0
Calculation: BearBias = DownBreakCount >= minimum break count AND ATRExpansionRatio > ATR expansion threshold AND close < EMA(close, bias EMA lookback) AND EMA(close, bias EMA lookback) - EMA(close, bias EMA lookback)[bias slope lookback] < 0
Long: BullBias AND StormScore >= storm score threshold AND at least cooldown bars since the preceding accepted long or short storm signal AND the current chart bar is confirmed
Short: BearBias AND StormScore >= storm score threshold AND at least cooldown bars since the preceding accepted long or short storm signal AND the current chart bar is confirmed
Long: UpBreakCount >= minimum break count
Short: DownBreakCount >= minimum break count
Long: AnchorPositionSum >= minimum bullish anchor sum
Long: BullBias AND StormScore >= storm score threshold × directional background score fraction
Short: BearBias AND StormScore >= storm score threshold × directional background score fraction