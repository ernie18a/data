Calculation: PoleAtr = (close - close[poleBars]) / ATR(atrBars)
Calculation: PoleEff = abs(close - close[poleBars]) / SUM(TR, poleBars)
Calculation: BullTrend = close > EMA(close, longTrendBars) OR EMA(close, shortTrendBars) > EMA(close, longTrendBars), where shortTrendBars is shorter than longTrendBars
Calculation: BearTrend = close < EMA(close, longTrendBars) OR EMA(close, shortTrendBars) < EMA(close, longTrendBars)
Calculation: PoleSide = (PoleAtr > minPoleAtrMult AND PoleEff >= minPoleEff AND BullTrend) ? 1 : (PoleAtr < -minPoleAtrMult AND PoleEff >= minPoleEff AND BearTrend) ? -1 : 0
Calculation: Age = CandidateAge[1] + 1
Calculation: NoCandidate = Age > candidateMaxBars OR LongBreak[1] OR ShortBreak[1]
Calculation: NewPole = PoleSide != 0 AND (NoCandidate OR PoleSide != sign(PoleAtr[Age]) OR abs(PoleAtr) > poleUpgradeMult * abs(PoleAtr[Age]))
Calculation: CandidateAge = 0 if NewPole, else Age if NOT NoCandidate, else none
Calculation: PoleMove = close[CandidateAge] - close[CandidateAge + poleBars]
Calculation: FlagHigh = highest(high[1], flagBars)
Calculation: FlagLow = lowest(low[1], flagBars)
Calculation: FlagRange = (FlagHigh - FlagLow) / abs(PoleMove)
Calculation: Depth = (close[CandidateAge] - FlagLow) / abs(PoleMove) if PoleMove > 0, else (FlagHigh - close[CandidateAge]) / abs(PoleMove)
Calculation: VolumePass = volume >= SMA(volume, volBars) * volMult
Calculation: FlagScore = round(clamp(clamp(abs(PoleAtr[CandidateAge]) / minPoleAtrMult * poleScoreWeight, 0, poleScoreCap) + clamp(PoleEff[CandidateAge] / minPoleEff * effScoreWeight, 0, effScoreCap) + clamp((1 - Depth / maxDepthRatio) * depthScoreWeight, 0, depthScoreCap) + clamp((1 - FlagRange / maxRangeRatio) * rangeScoreWeight, 0, rangeScoreCap) + compressionPts + ((PoleMove > 0 ? BullTrend : BearTrend) ? trendPts : trendLowPts) + (VolumePass ? volumePts : 0) + clamp(((PoleMove > 0 ? close - FlagHigh : FlagLow - close) / ATR(atrBars)) * breakScoreWeight, 0, breakScoreCap), 0, 100))
Calculation: QualifiedFlag = CandidateAge >= minWaitBars AND CandidateAge <= candidateMaxBars AND Depth >= -depthSlack AND Depth <= maxDepthRatio AND FlagRange <= maxRangeRatio AND sign(PoleMove) * (LinReg(close, flagBars, 0) - LinReg(close, flagBars, 1)) <= maxSlopeAtrMult * ATR(atrBars) AND sign(PoleMove) * (close - close[CandidateAge + poleBars]) > positionMargin * abs(PoleMove) AND FlagScore >= minQuality
Calculation: BarsSinceBreakout = 1 if LongBreak[1] OR ShortBreak[1], else BarsSinceBreakout[1] + 1
Calculation: BarsSinceSetupMark = 1 if SetupMark[1], else BarsSinceSetupMark[1] + 1
Calculation: SetupAlreadyMarked = NOT (LongBreak[1] OR ShortBreak[1] OR Age > candidateMaxBars OR (NewPole AND PoleSide != sign(PoleAtr[Age]))) AND (SetupAlreadyMarked[1] OR SetupMark[1])
Calculation: SetupMark = QualifiedFlag AND NOT SetupAlreadyMarked AND BarsSinceSetupMark > setupGapBars AND NOT (LongBreak OR ShortBreak)
Calculation: LongBreak = QualifiedFlag AND PoleMove > 0 AND close > FlagHigh + breakBufferAtrMult * ATR(atrBars) AND close > open AND VolumePass AND BarsSinceBreakout > breakGapBars
Calculation: ShortBreak = QualifiedFlag AND PoleMove < 0 AND close < FlagLow - breakBufferAtrMult * ATR(atrBars) AND close < open AND VolumePass AND BarsSinceBreakout > breakGapBars
Long: LongBreak
Long: SetupMark AND PoleMove > 0
Short: ShortBreak
Short: SetupMark AND PoleMove < 0
Exit: long, close < FlagLow at entry OR close >= entry price + min(entry price - FlagLow at entry, targetPoleMult * abs(PoleMove) at entry) OR bars since entry >= holdMaxBars
Exit: short, close > FlagHigh at entry OR close <= entry price - min(FlagHigh at entry - entry price, targetPoleMult * abs(PoleMove) at entry) OR bars since entry >= holdMaxBars