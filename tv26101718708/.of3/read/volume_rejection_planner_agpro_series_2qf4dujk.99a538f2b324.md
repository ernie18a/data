Calculation: RelVolume = volume / SMA(volume, volume baseline length)
Calculation: ATRValue = ATR(ATR length)
Calculation: RangeTop = Highest(high[1], edge lookback)
Calculation: RangeBottom = Lowest(low[1], edge lookback)
Calculation: CloseInRange = (close - low) / (high - low)
Calculation: UpperWick = high - max(open, close)
Calculation: LowerWick = min(open, close) - low
Calculation: UpperWickRatio = UpperWick / abs(close - open)
Calculation: LowerWickRatio = LowerWick / abs(close - open)
Calculation: HtfThresholdFactor = (HTF adaptation on AND chart timeframe is T2) ? T2 threshold factor : (HTF adaptation on AND chart timeframe is T1) ? T1 threshold factor : 1
Calculation: HtfScoreRelaxation = (HTF adaptation on AND chart timeframe is T2) ? T2 score relaxation : (HTF adaptation on AND chart timeframe is T1) ? T1 score relaxation : 0
Calculation: RvolNeed = base RVOL threshold * sensitivity RVOL multiplier * HtfThresholdFactor
Calculation: WickNeed = minimum wick ratio * sensitivity wick multiplier * HtfThresholdFactor
Calculation: FollowNeed = follow-through ATR * confirmation mode multiplier
Calculation: ScoreFloor = max(score floor, minimum score - HtfScoreRelaxation)
Calculation: NormHigh(v, weak, strong) = clamp(100 * (v - weak) / (strong - weak), 0, 100)
Calculation: NormLow(v, strong, weak) = clamp(100 * (weak - v) / (weak - strong), 0, 100)
Calculation: LongRejection = low <= RangeBottom + ATRValue * edge tolerance ATR AND RelVolume >= RvolNeed AND LowerWickRatio >= WickNeed AND LowerWick >= ATRValue * minimum wick ATR AND CloseInRange >= sensitivity close requirement
Calculation: ShortRejection = high >= RangeTop - ATRValue * edge tolerance ATR AND RelVolume >= RvolNeed AND UpperWickRatio >= WickNeed AND UpperWick >= ATRValue * minimum wick ATR AND CloseInRange <= 1 - sensitivity close requirement
Calculation: LongScore = round(min(100, close weight * CloseInRange + volume weight * NormHigh(RelVolume, volume start factor * RvolNeed, volume full factor * RvolNeed) + wick weight * NormHigh(LowerWickRatio, WickNeed, wick full factor * WickNeed) + wick size weight * NormHigh(LowerWick / ATRValue, minimum wick ATR, wick size full factor * minimum wick ATR) + edge weight * NormLow(abs(low - RangeBottom) / ATRValue, 0, edge full factor * edge tolerance ATR) + room weight * NormHigh((RangeTop - close) / ATRValue, room start ATR, room guide ATR)))
Calculation: ShortScore = round(min(100, close weight * (1 - CloseInRange) + volume weight * NormHigh(RelVolume, volume start factor * RvolNeed, volume full factor * RvolNeed) + wick weight * NormHigh(UpperWickRatio, WickNeed, wick full factor * WickNeed) + wick size weight * NormHigh(UpperWick / ATRValue, minimum wick ATR, wick size full factor * minimum wick ATR) + edge weight * NormLow(abs(RangeTop - high) / ATRValue, 0, edge full factor * edge tolerance ATR) + room weight * NormHigh((close - RangeBottom) / ATRValue, room start ATR, room guide ATR)))
Calculation: LongQualified = LongRejection AND LongScore >= ScoreFloor
Calculation: ShortQualified = ShortRejection AND ShortScore >= ScoreFloor
Calculation: EntryPrice = close at the most recent event bar
Calculation: EntryATR = ATRValue at the most recent event bar
Calculation: EntryLow = low at the most recent event bar
Calculation: EntryHigh = high at the most recent event bar
Calculation: LongFollowLevel = EntryPrice + EntryATR * FollowNeed
Calculation: ShortFollowLevel = EntryPrice - EntryATR * FollowNeed
Calculation: LongRiskEdge = EntryLow - EntryATR * risk buffer ATR
Calculation: ShortRiskEdge = EntryHigh + EntryATR * risk buffer ATR
Calculation: LongActiveScore = clamp(LongScore at the most recent event bar + progress weight * NormHigh((high - EntryPrice) / EntryATR, 0, FollowNeed) - pressure weight * NormHigh((EntryPrice - low) / EntryATR, pressure start factor * FollowNeed, pressure full factor * FollowNeed) - time weight * NormHigh(bars since the most recent event bar, time start factor * follow-through window, follow-through window), 0, 100)
Calculation: ShortActiveScore = clamp(ShortScore at the most recent event bar + progress weight * NormHigh((EntryPrice - low) / EntryATR, 0, FollowNeed) - pressure weight * NormHigh((high - EntryPrice) / EntryATR, pressure start factor * FollowNeed, pressure full factor * FollowNeed) - time weight * NormHigh(bars since the most recent event bar, time start factor * follow-through window, follow-through window), 0, 100)
Calculation: LongAcceptedNow = most recent event is long AND high >= LongFollowLevel AND no close since the most recent event bar below LongRiskEdge AND no high before this bar since the most recent event bar >= LongFollowLevel
Calculation: ShortAcceptedNow = most recent event is short AND low <= ShortFollowLevel AND no close since the most recent event bar above ShortRiskEdge AND no low before this bar since the most recent event bar <= ShortFollowLevel
Long: LongQualified AND (NOT ShortQualified OR LongScore >= ShortScore) AND bars since the previous event marking >= event cooldown
Short: ShortQualified AND (NOT LongQualified OR ShortScore > LongScore) AND bars since the previous event marking >= event cooldown
Long: LongAcceptedNow
Long: LongAcceptedNow AND LongActiveScore >= alert score
Short: ShortAcceptedNow
Short: ShortAcceptedNow AND ShortActiveScore >= alert score
Exit: long, close < LongRiskEdge
Exit: long, bars since the most recent event bar > follow-through window AND no high since the most recent event bar >= LongFollowLevel
Exit: short, close > ShortRiskEdge
Exit: short, bars since the most recent event bar > follow-through window AND no low since the most recent event bar <= ShortFollowLevel