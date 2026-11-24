Calculation: ZScore(x, n) = (x - SMA(x, n)) / STDEV(x, n), or 0 when STDEV(x, n) = 0
Calculation: LensRSI = ZScore(RSI(close, RsiWindow), NormWindow)
Calculation: LensKST = ZScore(KST(close, KstRoc1, KstRoc2, KstRoc3, KstRoc4, KstSmooth1, KstSmooth2, KstSmooth3, KstSmooth4), NormWindow), where KstRoc1 < KstRoc2 < KstRoc3 < KstRoc4
Calculation: LensLowLag = ZScore(clamp((UpSmooth - DownSmooth) / (UpSmooth + DownSmooth), -1, 1), NormWindow), where UpSmooth = EhlersTwoPole(max(close - close[1], 0), LowLagWindow), DownSmooth = EhlersTwoPole(max(close[1] - close, 0), LowLagWindow), and the ratio is 0 when UpSmooth + DownSmooth = 0
Calculation: FracDiff(x, d, w) = sum over k = 0 to w-1 of weight[k] * x[k], where weight[0] = 1 and weight[k] = -weight[k-1] * (d - k + 1) / k
Calculation: LensFracDiff = ZScore(FracDiff(log(close), FracOrder, FracWidth), NormWindow)
Calculation: LensEfficiency = ZScore(KaufmanER(close, EffWindow) * sign(close - close[EffWindow]), NormWindow)
Calculation: LensERGap = ZScore(KaufmanER(close, GapFastWindow) - KaufmanER(close, GapSlowWindow), NormWindow) * s, where s = sign(close - close[GapFastWindow]) with s = 1 when that sign is 0, and GapFastWindow < GapSlowWindow
Calculation: LensSAR = ZScore(clamp(SarExtent / ATR(AtrWindow), 0, 10), NormWindow) * SarSide, where SAR = ParabolicSAR(SarStep, SarStep, SarMax), SarSide = sign(close - SAR), and SarExtent = high - SAR if SarSide = 1, SAR - low if SarSide = -1, else 0
Calculation: LensLinReg = ZScore((close - LinReg(close, LinRegWindow, 0)) / ATR(AtrWindow), NormWindow)
Calculation: LensVWAP = ZScore(close - VWAP((high + low + close) / 3), NormWindow)
Calculation: LensRange = ZScore(high - low, NormWindow) * s, where s = sign(close - close[RangeWindow]) with s = 1 when that sign is 0
Calculation: LensVRP = ZScore(ZScore(VolatilityIndexClose, NormWindow) - ZScore(STDEV(log(close / close[1]), VrpWindow), NormWindow), NormWindow)
Calculation: LensVIX = -ZScore(VolatilityIndexClose, NormWindow)
Calculation: LensBasis = ZScore(close - SpotClose, NormWindow)
Calculation: LensCVD = ZScore(CVD(SignedVolume) - EMA(CVD(SignedVolume), NormWindow), NormWindow), where CVD(x) is the running sum of x from the first bar
Calculation: LensMFI = ZScore(MFI((high + low + close) / 3, MfiWindow), NormWindow)
Calculation: SignedVolume = sum over the T1 bars that make up the current chart bar of volume * sign(bar close - bar open); if there are no such T1 bars, volume * (2 * bf - 1) where bf = (close - low) / (high - low), or 0.5 when high = low
Calculation: Composite = average of the available values among LensRSI, LensKST, LensLowLag, LensFracDiff, LensEfficiency, LensSAR, LensERGap, LensVWAP, LensLinReg, LensRange, LensVRP, LensCVD, LensMFI, LensBasis, LensVIX
Calculation: AspOscillatory = average of the available values among LensRSI and LensKST
Calculation: FamilyNet(f) = average of the available members of family f, where Momentum = {AspOscillatory, LensLowLag, LensFracDiff}, Trend = {LensEfficiency, LensSAR, LensERGap}, Location = {LensVWAP, LensLinReg}, Volatility = {LensRange, LensVRP}, Flow = {LensCVD, LensMFI}, CrossAsset = {LensBasis, LensVIX}
Calculation: FamilySplit(f) = some member of f >= LeanSigma AND some member of f <= -LeanSigma
Calculation: ActiveFamilies = number of families f whose FamilyNet(f) is available
Calculation: ExtremeUpFamilies = number of families f with some member of f >= ExtremeSigma
Calculation: ExtremeDownFamilies = number of families f with some member of f <= -ExtremeSigma
Calculation: SplitFamilies = number of families f with FamilySplit(f)
Calculation: BullFamilies = number of families f with FamilyNet(f) > 0 AND NOT FamilySplit(f)
Calculation: BearFamilies = number of families f with FamilyNet(f) < 0 AND NOT FamilySplit(f)
Calculation: RequiredFamilies = min(MinFamilies, max(1, ActiveFamilies))
Calculation: OBLevel = CompositeOBMult * STDEV(Composite, CompositeWindow) if that is available and > 0, else OverboughtSigma
Calculation: ExtLevel = CompositeExtMult * STDEV(Composite, CompositeWindow) if that is available and > 0, else ExtremeSigma
Calculation: BearDet = Highest(Composite, 2 * PivotBars + 1)
Calculation: BullDet = Lowest(Composite, 2 * PivotBars + 1)
Calculation: GapThreshold = GapMult * STDEV(Composite, GapStdevWindow)
Calculation: GatedHighPivot = PivotHigh(high, PivotBars, PivotBars) is not NA AND a previous high pivot is stored AND (bar index - PivotBars) - PrevHighPivot.Bar <= MaxPivotGap
Calculation: GatedLowPivot = PivotLow(low, PivotBars, PivotBars) is not NA AND a previous low pivot is stored AND (bar index - PivotBars) - PrevLowPivot.Bar <= MaxPivotGap
Calculation: PrevHighPivot = values stored at the most recent high pivot before this bar, where each bar with PivotHigh(high, PivotBars, PivotBars) not NA stores Price = high[PivotBars], Det = BearDet at that bar, Family(f) = FamilyNet(f)[PivotBars] for each family f, and Bar = bar index - PivotBars
Calculation: PrevLowPivot = values stored at the most recent low pivot before this bar, where each bar with PivotLow(low, PivotBars, PivotBars) not NA stores Price = low[PivotBars], Det = BullDet at that bar, Family(f) = FamilyNet(f)[PivotBars] for each family f, and Bar = bar index - PivotBars
Calculation: RegularBear = GatedHighPivot AND high[PivotBars] > PrevHighPivot.Price AND BearDet < PrevHighPivot.Det AND PrevHighPivot.Det - BearDet >= GapThreshold AND BearDet >= OBLevel
Calculation: ExaggeratedBear = GatedHighPivot AND abs(high[PivotBars] - PrevHighPivot.Price) <= EqualTol * ATR(AtrWindow) AND BearDet < PrevHighPivot.Det AND PrevHighPivot.Det - BearDet >= GapThreshold AND BearDet >= OBLevel
Calculation: HiddenBear = GatedHighPivot AND high[PivotBars] < PrevHighPivot.Price AND BearDet > PrevHighPivot.Det AND BearDet - PrevHighPivot.Det >= GapThreshold
Calculation: RegularBull = GatedLowPivot AND low[PivotBars] < PrevLowPivot.Price AND BullDet > PrevLowPivot.Det AND BullDet - PrevLowPivot.Det >= GapThreshold AND BullDet <= -OBLevel
Calculation: ExaggeratedBull = GatedLowPivot AND abs(low[PivotBars] - PrevLowPivot.Price) <= EqualTol * ATR(AtrWindow) AND BullDet > PrevLowPivot.Det AND BullDet - PrevLowPivot.Det >= GapThreshold AND BullDet <= -OBLevel
Calculation: HiddenBull = GatedLowPivot AND low[PivotBars] > PrevLowPivot.Price AND BullDet < PrevLowPivot.Det AND PrevLowPivot.Det - BullDet >= GapThreshold
Calculation: BearRun = (BearRun at the previous GatedHighPivot) + 1 when RegularBear OR ExaggeratedBear, else 0; updated only on bars where GatedHighPivot holds
Calculation: BullRun = (BullRun at the previous GatedLowPivot) + 1 when RegularBull OR ExaggeratedBull, else 0; updated only on bars where GatedLowPivot holds
Calculation: DivergenceCountBear = number of families f with FamilyNet(f)[PivotBars] < PrevHighPivot.Family(f), counted only when high[PivotBars] > PrevHighPivot.Price or abs(high[PivotBars] - PrevHighPivot.Price) <= EqualTol * ATR(AtrWindow), otherwise 0
Calculation: DivergenceCountBull = number of families f with FamilyNet(f)[PivotBars] > PrevLowPivot.Family(f), counted only when low[PivotBars] < PrevLowPivot.Price or abs(low[PivotBars] - PrevLowPivot.Price) <= EqualTol * ATR(AtrWindow), otherwise 0
Calculation: LeadingSplitBear = SplitFamilies > 0 AND Composite >= OBLevel
Calculation: LeadingSplitBull = SplitFamilies > 0 AND Composite <= -OBLevel
Calculation: SlopeDisagreeBear = LinRegSlope(close, SlopeWindow) > 0 AND LinRegSlope(Composite, SlopeWindow) < 0
Calculation: SlopeDisagreeBull = LinRegSlope(close, SlopeWindow) < 0 AND LinRegSlope(Composite, SlopeWindow) > 0
Calculation: HeldDivergenceDir = the most recent nonzero DivergencePulse if it occurred 7 or fewer bars ago (current bar = 0 bars ago), otherwise 0, where DivergencePulse = 1 if RegularBull OR ExaggeratedBull, -1 if RegularBear OR ExaggeratedBear, else 0
Long: Composite <= -OBLevel
Long: ExtremeDownFamilies >= RequiredFamilies
Long: RegularBull OR ExaggeratedBull
Long: HiddenBull
Long: GatedLowPivot AND BullRun >= 3
Long: GatedLowPivot AND DivergenceCountBull >= RequiredFamilies
Long: LeadingSplitBull AND NOT LeadingSplitBull[1]
Long: SlopeDisagreeBull AND NOT SlopeDisagreeBull[1]
Long: Correlation(close, Composite, CorrWindow) crosses below CorrLevel AND LinRegSlope(close, SlopeWindow) < 0
Long: RSI(close, RsiWindow) < RSI(close, RsiWindow)[1] AND RSI(close, RsiWindow)[1] < RSI(close, RsiWindow)[2] AND RSI(close, RsiWindow)[2] < RSI(close, RsiWindow)[3] AND RSI(close, RsiWindow)[3] < SeqOversold AND RSI(close, RsiWindow)[4] > SeqOversold
Long: PivotLow(Composite, ReversalPivotBars, ReversalPivotBars) <= -ExtLevel
Long: HeldDivergenceDir > 0
Long: FamilyNet(f) > 0 AND NOT FamilySplit(f) for some family f
Long: BullFamilies > BearFamilies
Short: Composite >= OBLevel
Short: ExtremeUpFamilies >= RequiredFamilies
Short: RegularBear OR ExaggeratedBear
Short: HiddenBear
Short: GatedHighPivot AND BearRun >= 3
Short: GatedHighPivot AND DivergenceCountBear >= RequiredFamilies
Short: LeadingSplitBear AND NOT LeadingSplitBear[1]
Short: SlopeDisagreeBear AND NOT SlopeDisagreeBear[1]
Short: Correlation(close, Composite, CorrWindow) crosses below CorrLevel AND LinRegSlope(close, SlopeWindow) > 0
Short: RSI(close, RsiWindow) > RSI(close, RsiWindow)[1] AND RSI(close, RsiWindow)[1] > RSI(close, RsiWindow)[2] AND RSI(close, RsiWindow)[2] > RSI(close, RsiWindow)[3] AND RSI(close, RsiWindow)[3] > SeqOverbought AND RSI(close, RsiWindow)[4] < SeqOverbought
Short: PivotHigh(Composite, ReversalPivotBars, ReversalPivotBars) >= ExtLevel
Short: HeldDivergenceDir < 0
Short: FamilyNet(f) < 0 AND NOT FamilySplit(f) for some family f
Short: BearFamilies > BullFamilies