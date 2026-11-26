Calculation: AsiaHigh = highest high of the most recent completed run of bars with UTC hour >= Asia start hour AND UTC hour < Asia end hour
Calculation: AsiaLow = lowest low of the most recent completed run of bars with UTC hour >= Asia start hour AND UTC hour < Asia end hour
Calculation: RoundAbove = ceiling(close / round step) * round step
Calculation: RoundBelow = floor(close / round step) * round step
Calculation: LowSweep(level) = low < level AND close > level AND (min(open, close) - low) > (high - low) * sweep wick threshold
Calculation: HighSweep(level) = high > level AND close < level AND (high - max(open, close)) > (high - low) * sweep wick threshold
Calculation: AnyBullSweep = LowSweep(AsiaLow) OR LowSweep(Low(T1, last completed bar)) OR LowSweep(most recent confirmed PivotLow(low, swing lookback, swing lookback)) OR LowSweep(RoundBelow)
Calculation: AnyBearSweep = HighSweep(AsiaHigh) OR HighSweep(High(T1, last completed bar)) OR HighSweep(most recent confirmed PivotHigh(high, swing lookback, swing lookback)) OR HighSweep(RoundAbove)
Calculation: BodyToRange = abs(close - open) / (high - low)
Calculation: RangeExpanded = (high - low) > ATR(ATR length) * ATR expansion
Calculation: BullSweepDisplacement = close > open AND BodyToRange > body ratio threshold AND RangeExpanded AND BarsSince(AnyBullSweep) <= displacement window
Calculation: BearSweepDisplacement = close < open AND BodyToRange > body ratio threshold AND RangeExpanded AND BarsSince(AnyBearSweep) <= displacement window
Calculation: DeadSession = UTC hour >= dead start hour OR UTC hour < dead end hour
Calculation: Killzone = (UTC hour >= London start hour AND UTC hour < London end hour) OR (UTC hour >= NY start hour AND UTC hour < NY end hour)
Calculation: HigherHighHigherLow = (last confirmed PivotHigh(high, structure lookback, structure lookback) > the confirmed PivotHigh before it) AND (last confirmed PivotLow(low, structure lookback, structure lookback) > the confirmed PivotLow before it)
Calculation: LowerHighLowerLow = (last confirmed PivotHigh(high, structure lookback, structure lookback) < the confirmed PivotHigh before it) AND (last confirmed PivotLow(low, structure lookback, structure lookback) < the confirmed PivotLow before it)
Calculation: BullBias = (EMA(close, shorter lookback) > EMA(close, longer lookback) AND EMA(close, longer lookback) > EMA(close, longest lookback) AND EMA(close, shorter lookback) > EMA(close, shorter lookback)[slope length]) OR (HigherHighHigherLow AND close > EMA(close, longest lookback))
Calculation: BearBias = (EMA(close, shorter lookback) < EMA(close, longer lookback) AND EMA(close, longer lookback) < EMA(close, longest lookback) AND EMA(close, shorter lookback) < EMA(close, shorter lookback)[slope length]) OR (LowerHighLowerLow AND close < EMA(close, longest lookback))
Calculation: BullZone = (top: low, bottom: high[2]) if FVG zones enabled AND low > high[2] AND (low - high[2]) / close * 100 > FVG min size; else (top: high[1], bottom: low[1]) if OB zones enabled AND close[1] < open[1]; else undefined
Calculation: BearZone = (top: low[2], bottom: high) if FVG zones enabled AND high < low[2] AND (low[2] - high) / close * 100 > FVG min size; else (top: high[1], bottom: low[1]) if OB zones enabled AND close[1] > open[1]; else undefined
Calculation: BullLiquidityGrade = premium liquidity quality if LowSweep(AsiaLow) OR LowSweep(Low(T1, last completed bar)), else base liquidity quality
Calculation: BearLiquidityGrade = premium liquidity quality if HighSweep(AsiaHigh) OR HighSweep(High(T1, last completed bar)), else base liquidity quality
Calculation: BullScore = liquidity weight * BullLiquidityGrade + displacement weight + inefficiency weight + (session weight if Killzone) + (bias weight if BullBias)
Calculation: BearScore = liquidity weight * BearLiquidityGrade + displacement weight + inefficiency weight + (session weight if Killzone) + (bias weight if BearBias)
Calculation: ZoneCreated = BullZoneCreated OR BearZoneCreated
Calculation: BullZoneCreated = BullSweepDisplacement AND NOT DeadSession AND BullZone is defined AND BullScore >= min draw score AND NOT ZoneCreated on any of the previous (zone spacing - 1) bars
Calculation: BearZoneCreated = BearSweepDisplacement AND NOT DeadSession AND BearZone is defined AND BearScore >= min draw score AND NOT ZoneCreated on any of the previous (zone spacing - 1) bars
Calculation: BullRetest(b) = low <= BullZone(b).top AND close > BullZone(b).top
Calculation: BullMitigated(b) = low < BullZone(b).top - (BullZone(b).top - BullZone(b).bottom) * mitigation percent / 100
Calculation: BearRetest(b) = high >= BearZone(b).bottom AND close < BearZone(b).bottom
Calculation: BearMitigated(b) = high > BearZone(b).bottom + (BearZone(b).top - BearZone(b).bottom) * mitigation percent / 100
Calculation: BullArmingZone(b) = BullZoneCreated at bar b AND now - b <= zone expiry AND (count of bars j with b < j < now where ZoneCreated) < max active zones AND for every bar j from b to now, NOT BullMitigated(b) at bar j AND BullRetest(b) AND for every bar j from b to before now, NOT BullRetest(b) at bar j
Calculation: BearArmingZone(b) = BearZoneCreated at bar b AND now - b <= zone expiry AND (count of bars j with b < j < now where ZoneCreated) < max active zones AND for every bar j from b to now, NOT BearMitigated(b) at bar j AND BearRetest(b) AND for every bar j from b to before now, NOT BearRetest(b) at bar j
Calculation: BullArmedScore = maximum over bars b with BullArmingZone(b) of (BullScore at bar b + confirmation weight)
Calculation: BearArmedScore = maximum over bars b with BearArmingZone(b) of (BearScore at bar b + confirmation weight)
Long: AnyBullSweep AND NOT DeadSession
Long: AnyBullSweep
Long: BullSweepDisplacement
Long: BullZoneCreated
Long: BullArmingZone(b) for some bar b
Long: BullArmedScore >= A score OR BullArmedScore >= A+ score
Short: AnyBearSweep AND NOT DeadSession
Short: AnyBearSweep
Short: BearSweepDisplacement
Short: BearZoneCreated
Short: BearArmingZone(b) for some bar b
Short: BearArmedScore >= A score OR BearArmedScore >= A+ score