Calculation: TypicalPrice = (high + low + close) / 3
Calculation: HighPass = (TypicalPrice - TypicalPrice[1]) + (1 - hpAlpha) * HighPass[1]
Calculation: BandPass = lpAlpha * HighPass + (1 - lpAlpha) * BandPass[1]
Calculation: RobustZ(x, n) = (x - Median(x, n)) / D, where D = 1.4826 * MAD(x, n) if MAD(x, n) != 0, else StDev(x, n); RobustZ is 0 if D = 0
Calculation: MomentumFactor = Clamp(EMA(RobustZ(BandPass, shortLookback), momEmaLen), -momClip, momClip) / momClip
Calculation: KatzTrend(n) = 1 - 2 * Clamp(KatzFD(TypicalPrice, n) - 1, 0, 1)
Calculation: KatzFactor = (KatzTrend(shortLookback) + KatzTrend(coreLookback) + KatzTrend(longLookback)) / 3, with shortLookback < coreLookback < longLookback
Calculation: Hurst = HurstExponent(close, hurstScale1, hurstScale2, hurstScale3), with hurstScale1 < hurstScale2 < hurstScale3
Calculation: HurstFactor = 2 * (Hurst - 0.5)
Calculation: TrendFactor = (MomentumFactor + KatzFactor + HurstFactor) / 3
Calculation: RangePosition(x, n) = (x - Lowest(x, n)) / (Highest(x, n) - Lowest(x, n)), or 0.5 if the denominator is 0
Calculation: RegimeBias = (HurstFactor + 1 - 2 * RangePosition(KatzFD(TypicalPrice, coreLookback), coreLookback)) / 2
Calculation: TrendWeight = Clamp(trendWeightBase + trendWeightSlope * RegimeBias, trendWeightMin, trendWeightMax)
Calculation: EntropyWeight = Clamp(entWeightBase - entWeightSlope * RegimeBias, entWeightMin, entWeightMax)
Calculation: Change = TypicalPrice - TypicalPrice[1]
Calculation: Bin = min(histogramBins - 1, floor(histogramBins * Clamp((Change - Lowest(Change, retLookback)) / max(Highest(Change, retLookback) - Lowest(Change, retLookback), 1e-12), 0, 1)))
Calculation: HistogramCount(i) = Round((1 - 2 / (retLookback + 1)) * HistogramCount(i)[1]) + (1 if Bin = i else 0), for each bin index i from 0 to histogramBins - 1
Calculation: NormalizedEntropy = -(sum over i of p_i * ln(p_i)) / ln(histogramBins), where p_i = HistogramCount(i) / (sum over j of HistogramCount(j)) and terms with p_i = 0 are 0
Calculation: EntropyFactor = 1 - 2 * NormalizedEntropy
Calculation: CompositeOscillator = EMA(weightSum * (TrendWeight * TrendFactor + EntropyWeight * EntropyFactor) / (TrendWeight + EntropyWeight), smoothLen)
Calculation: ConfidenceProxy = Clamp(1 - abs(TrendFactor - EntropyFactor), 0, 1)
Calculation: ChopRegime = abs(CompositeOscillator) <= neutralBand OR Hurst < chopHurst OR NormalizedEntropy > chopEntropy
Calculation: TrendUp = CompositeOscillator > neutralBand AND TrendFactor > 0 AND NOT ChopRegime
Calculation: TrendDown = CompositeOscillator < -neutralBand AND TrendFactor < 0 AND NOT ChopRegime
Long: CompositeOscillator > thrustLevel AND ConfidenceProxy > thrustConfidence
Short: CompositeOscillator < -thrustLevel AND ConfidenceProxy > thrustConfidence
Long: CompositeOscillator crosses below -revertLevel AND ChopRegime AND ConfidenceProxy >= confidenceFloor
Short: CompositeOscillator crosses above revertLevel AND ChopRegime AND ConfidenceProxy >= confidenceFloor
Long: CompositeOscillator crosses above neutralBand AND NOT ChopRegime AND ConfidenceProxy >= confidenceFloor
Short: CompositeOscillator crosses below -neutralBand AND NOT ChopRegime AND ConfidenceProxy >= confidenceFloor
Long: CompositeOscillator crosses above trendEntryLevel AND CompositeOscillator > trendFilterLevel AND TrendUp AND ConfidenceProxy > trendConfidence
Short: CompositeOscillator crosses below -trendEntryLevel AND CompositeOscillator < -trendFilterLevel AND TrendDown AND ConfidenceProxy > trendConfidence
Long: TrendUp AND ConfidenceProxy >= confidenceFloor
Short: TrendDown AND ConfidenceProxy >= confidenceFloor
Long: CompositeOscillator < -colorLevel AND ConfidenceProxy >= confidenceFloor
Short: CompositeOscillator > colorLevel AND ConfidenceProxy >= confidenceFloor
Exit: long, CompositeOscillator <= neutralBand OR ConfidenceProxy < exitConfidence
Exit: short, CompositeOscillator >= -neutralBand OR ConfidenceProxy < exitConfidence
Exit: long, CompositeOscillator crosses above 0
Exit: short, CompositeOscillator crosses below 0