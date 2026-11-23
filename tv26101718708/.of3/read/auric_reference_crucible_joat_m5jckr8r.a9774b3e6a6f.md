Calculation: AvgTrueRange = ATR(high, low, close, ATR length)
Calculation: TouchBand = AvgTrueRange * touch multiplier
Calculation: BarRange = MAX(high - low, tick size)
Calculation: BarBody = MAX(ABS(close - open), tick size)
Calculation: Ref(A) = IF A == T1Open THEN open of the forming T1 bar ELSE IF A == T2Open THEN open of the forming T2 bar ELSE IF A == T3Open THEN open of the forming T3 bar ELSE close of the last completed T1 bar, each taken on chart bars
Calculation: NewBar(A) = the current chart bar is the first chart bar of a new bar of timeframe T2 if A == T2Open, T3 if A == T3Open, otherwise T1
Calculation: InBand(A) = low <= Ref(A) + TouchBand AND high >= Ref(A) - TouchBand
Calculation: CrossUp(A) = close > Ref(A) + TouchBand AND close[1] <= Ref(A)
Calculation: CrossDown(A) = close < Ref(A) - TouchBand AND close[1] >= Ref(A)
Calculation: BullReject(A) = InBand(A) AND close > Ref(A) AND MIN(open, close) - low > BarBody * wick multiple AND close > low + BarRange * bull close fraction
Calculation: BearReject(A) = InBand(A) AND close < Ref(A) AND high - MAX(open, close) > BarBody * wick multiple AND close < low + BarRange * bear close fraction
Calculation: Reject(A) = BullReject(A) OR BearReject(A)
Calculation: Count(A) = IF (close > Ref(A) + TouchBand AND Bias(A)[1] <= 0) OR (close < Ref(A) - TouchBand AND Bias(A)[1] >= 0) THEN (IF NewBar(A) THEN 0 ELSE Count(A)[1]) + 1 ELSE 0, with Count(A)[1] = 0 before the first bar
Calculation: Reclaim(A) = (CrossUp(A) OR CrossDown(A)) AND (Count(A) >= confirmation bars OR confirmation bars <= 1)
Calculation: PriorState(A) = IF NewBar(A) THEN Untouched ELSE AnchorState(A)[1]
Calculation: AnchorState(A) = IF PriorState(A) == Reclaimed AND InBand(A) AND NOT Reject(A) THEN Held ELSE IF Reclaim(A) THEN Reclaimed ELSE IF Reject(A) THEN Rejected ELSE IF InBand(A) THEN (IF PriorState(A) == Untouched THEN Touched ELSE Tested) ELSE PriorState(A), with AnchorState(A)[1] = Untouched before the first bar
Calculation: Bias(A) = IF CrossUp(A) THEN 1 ELSE IF CrossDown(A) THEN -1 ELSE IF Reject(A) THEN (IF BullReject(A) THEN 1 ELSE -1) ELSE IF PriorState(A) == Untouched AND InBand(A) THEN (IF close >= Ref(A) THEN 1 ELSE -1) ELSE Bias(A)[1], with Bias(A)[1] = 1 before the first bar
Calculation: StateWeight(S) = IF S == Reclaimed THEN reclaimed weight ELSE IF S == Rejected THEN rejected weight ELSE IF S == Touched THEN touched weight ELSE IF S == Tested THEN tested weight ELSE IF S == Held THEN held weight ELSE IF S == Untouched THEN untouched weight ELSE 0
Calculation: AnchorScore(A) = IF anchor A is enabled THEN MAX(0, 1 - ABS(close - Ref(A)) / AvgTrueRange / fade distance multiple) * StateWeight(AnchorState(A)) ELSE 0
Calculation: BestScore = MAX(AnchorScore(T1Open), AnchorScore(T2Open), AnchorScore(T3Open), AnchorScore(T1PrevClose))
Calculation: ControlAnchor = the first of T1Open, T2Open, T3Open, T1PrevClose whose AnchorScore == BestScore
Calculation: ControlPrice = Ref(ControlAnchor)
Calculation: ControlBias = Bias(ControlAnchor)
Calculation: TrendMean = EMA(close, trend length)
Calculation: TrendSlope = TrendMean - TrendMean[slope lookback]
Calculation: BodyDirection = IF close > open THEN 1 ELSE IF close < open THEN 0 ELSE 0.5
Calculation: BuyShare = MIN(1, MAX(0, (close - low) / BarRange * close position weight + BodyDirection * body direction weight + ABS(close - open) / BarRange * (BodyDirection - 0.5) * body power weight + share offset))
Calculation: FlowScore = SUM(volume * (2 * BuyShare - 1), flow window) / SUM(volume, flow window)
Calculation: AnyReclaim = Reclaim(T1Open) OR Reclaim(T2Open) OR Reclaim(T3Open) OR Reclaim(T1PrevClose)
Calculation: LongGrade = MIN(100, MAX(0, (IF BestScore >= minimum anchor score THEN setup bonus ELSE BestScore * per point weight) + (IF close > TrendMean AND TrendSlope >= 0 THEN trend strong bonus ELSE IF close > TrendMean THEN trend weak bonus ELSE 0) + (IF FlowScore > flow threshold THEN flow strong bonus ELSE IF FlowScore > 0 THEN flow weak bonus ELSE 0) + (IF ControlBias >= 0 THEN control bias bonus ELSE 0) + (IF (high >= ControlPrice - TouchBand AND low <= ControlPrice + TouchBand) OR ABS(close - ControlPrice) / AvgTrueRange <= control distance limit THEN control proximity bonus ELSE 0) + (IF close > open THEN bar body bonus ELSE 0) + (IF AnyReclaim THEN reclaim bonus ELSE 0)))
Calculation: ShortGrade = MIN(100, MAX(0, (IF BestScore >= minimum anchor score THEN setup bonus ELSE BestScore * per point weight) + (IF close < TrendMean AND TrendSlope <= 0 THEN trend strong bonus ELSE IF close < TrendMean THEN trend weak bonus ELSE 0) + (IF FlowScore < -flow threshold THEN flow strong bonus ELSE IF FlowScore < 0 THEN flow weak bonus ELSE 0) + (IF ControlBias < 0 THEN control bias bonus ELSE 0) + (IF (high >= ControlPrice - TouchBand AND low <= ControlPrice + TouchBand) OR ABS(close - ControlPrice) / AvgTrueRange <= control distance limit THEN control proximity bonus ELSE 0) + (IF close < open THEN bar body bonus ELSE 0) + (IF AnyReclaim THEN reclaim bonus ELSE 0)))
Calculation: LongCore = (for some anchor A, (Reclaim(A) OR Reject(A)) AND Bias(A) >= 0) AND BestScore >= minimum anchor score AND LongGrade >= grade threshold AND LongGrade > ShortGrade
Calculation: ShortCore = (for some anchor A, (Reclaim(A) OR Reject(A)) AND Bias(A) < 0) AND BestScore >= minimum anchor score AND ShortGrade >= grade threshold AND ShortGrade > LongGrade
Calculation: CooldownReady = NOT (EntryFired[n] for any n from 1 to cooldown bars)
Calculation: EntryFired = (LongCore OR ShortCore) AND CooldownReady
Long: LongCore AND CooldownReady
Short: ShortCore AND CooldownReady
Long: BestScore > 0 AND close >= ControlPrice
Short: BestScore > 0 AND close < ControlPrice