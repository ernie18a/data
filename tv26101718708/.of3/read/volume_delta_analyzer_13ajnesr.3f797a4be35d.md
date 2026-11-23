Calculation: BarDelta = for each completed chart bar, the sum over the T0 bars inside it of (buy volume - sell volume); if it has no T0 bars, IF High > Low THEN Volume * (Close - Open) / (High - Low) ELSE 0
Calculation: CumDelta = CumDelta[1] + BarDelta
Calculation: LowPivotPrice = Low[PivotBars] if PivotLow(Low, PivotBars, PivotBars) is defined on the current bar, else LowPivotPrice[1]
Calculation: LowPivotCumDelta = CumDelta[PivotBars] if PivotLow(Low, PivotBars, PivotBars) is defined on the current bar, else LowPivotCumDelta[1]
Calculation: LowPivotBar = current bar index - PivotBars if PivotLow(Low, PivotBars, PivotBars) is defined on the current bar, else LowPivotBar[1]
Calculation: LowPivotGap = LowPivotBar - LowPivotBar[1]
Calculation: LowPivotSwing = ABS(LowPivotPrice - LowPivotPrice[1])
Calculation: HighPivotPrice = High[PivotBars] if PivotHigh(High, PivotBars, PivotBars) is defined on the current bar, else HighPivotPrice[1]
Calculation: HighPivotCumDelta = CumDelta[PivotBars] if PivotHigh(High, PivotBars, PivotBars) is defined on the current bar, else HighPivotCumDelta[1]
Calculation: HighPivotBar = current bar index - PivotBars if PivotHigh(High, PivotBars, PivotBars) is defined on the current bar, else HighPivotBar[1]
Calculation: HighPivotGap = HighPivotBar - HighPivotBar[1]
Calculation: HighPivotSwing = ABS(HighPivotPrice - HighPivotPrice[1])
Calculation: VolumeRatio = Volume / SMA(Volume, VolumeAverageBars), or 1 if that SMA is 0
Calculation: BodyRatio = ABS(Close - Open) / (High - Low), or 1 if High = Low
Calculation: NormCumDelta = (CumDelta - Lowest(CumDelta, CumDeltaLookback)) / (Highest(CumDelta, CumDeltaLookback) - Lowest(CumDelta, CumDeltaLookback)), or 0.5 if that denominator is 0
Long: ExhaustionOn AND LowPivotPrice < LowPivotPrice[1] AND LowPivotCumDelta > LowPivotCumDelta[1] AND LowPivotGap >= PivotBars AND LowPivotGap <= MaxPivotSpacing AND LowPivotSwing >= ATR(ATRPeriod) * MinSwingInATR AND (bars since this line last held >= CooldownBars OR this line never held)
Long: AbsorptionDivOn AND LowPivotPrice > LowPivotPrice[1] AND LowPivotCumDelta < LowPivotCumDelta[1] AND LowPivotGap >= PivotBars AND LowPivotGap <= MaxPivotSpacing AND LowPivotSwing >= ATR(ATRPeriod) * MinSwingInATR AND (bars since this line last held >= CooldownBars OR this line never held)
Short: ExhaustionOn AND HighPivotPrice > HighPivotPrice[1] AND HighPivotCumDelta < HighPivotCumDelta[1] AND HighPivotGap >= PivotBars AND HighPivotGap <= MaxPivotSpacing AND HighPivotSwing >= ATR(ATRPeriod) * MinSwingInATR AND (bars since this line last held >= CooldownBars OR this line never held)
Short: AbsorptionDivOn AND HighPivotPrice < HighPivotPrice[1] AND HighPivotCumDelta > HighPivotCumDelta[1] AND HighPivotGap >= PivotBars AND HighPivotGap <= MaxPivotSpacing AND HighPivotSwing >= ATR(ATRPeriod) * MinSwingInATR AND (bars since this line last held >= CooldownBars OR this line never held)
Long: AbsorptionCandleOn AND VolumeRatio >= VolumeSpikeMultiple AND BodyRatio <= MaxBodyShare AND Close >= High - CloseZoneShare * (High - Low) AND (BarDelta < 0 OR DeltaConfirmation is off)
Short: AbsorptionCandleOn AND VolumeRatio >= VolumeSpikeMultiple AND BodyRatio <= MaxBodyShare AND Close <= Low + CloseZoneShare * (High - Low) AND (BarDelta > 0 OR DeltaConfirmation is off)
Long: BarColoringOn AND BarDelta >= 0
Short: BarColoringOn AND BarDelta < 0
Long: RibbonOn AND NormCumDelta >= NormCumDelta[1]
Short: RibbonOn AND NormCumDelta < NormCumDelta[1]