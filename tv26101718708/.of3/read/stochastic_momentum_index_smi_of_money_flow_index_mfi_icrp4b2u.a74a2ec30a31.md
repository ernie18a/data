Calculation: SMI = SMI(MFI(MFISource, MFILength), KLength, DLength, SMISmoothingType) on T1 bars, with chart bars taking the value of the T1 bar still forming
Calculation: SignalLine = MA(SMI, SignalLength, SignalSmoothingType) on T1 bars, with chart bars taking the value of the T1 bar still forming
Calculation: SMIErgodicHistogram = histogram output of SMI(MFI(HistogramMFISource, HistogramMFILength), HistogramKLength, HistogramDLength, HistogramSMISmoothingType) with signal MA(SMI, HistogramSignalLength, HistogramSignalSmoothingType), times HistogramMultiplier, on T1 bars, with chart bars taking the value of the T1 bar still forming
Calculation: DynamicZoneTop = PercentileNearestRank(SMI, DZSampleLength, UpperPercentile) on T1 bars, with chart bars taking the value of the T1 bar still forming
Calculation: DynamicZoneBottom = PercentileNearestRank(SMI, DZSampleLength, 100 - LowerPercentile) on T1 bars, with chart bars taking the value of the T1 bar still forming
Calculation: DynamicZoneCenter = PercentileNearestRank(SMI, DZSampleLength, CenterPercentile) on T1 bars, with chart bars taking the value of the T1 bar still forming
Calculation: TrendSeries = SMI or SMIErgodicHistogram, as selected by TrendSource
Calculation: PivotHighLine = value at the current bar of the most recent line through two consecutive pivot highs of TrendSeries, PivotHigh(TrendSeries, 1, TrendPivotLookback), in which the later pivot high is below the earlier
Calculation: PivotLowLine = value at the current bar of the most recent line through two consecutive pivot lows of TrendSeries, PivotLow(TrendSeries, 1, TrendPivotLookback), in which the later pivot low is above the earlier
Calculation: DivergenceOscillator = SMI or SMIErgodicHistogram, as selected by DivergenceSource
Calculation: PivotLowConfirmed = PivotLow(DivergenceOscillator, DivergenceLeftBars, DivergenceRightBars) is not NA
Calculation: PivotHighConfirmed = PivotHigh(DivergenceOscillator, DivergenceLeftBars, DivergenceRightBars) is not NA
Long: SignalLine crosses above TextBuyLevel
Short: SignalLine crosses below TextSellLevel
Long: SMI[1] <= Alert1BelowLevel AND (SMI[1] < DynamicZoneBottom OR SMI[1] > DynamicZoneTop) AND SMI crosses above SignalLine
Short: SMI[1] >= Alert1AboveLevel AND (SMI[1] < DynamicZoneBottom OR SMI[1] > DynamicZoneTop) AND SMI crosses below SignalLine
Long: SMI[1] <= Alert2BelowLevel AND SMI[1] >= DynamicZoneBottom AND SMI[1] <= DynamicZoneTop AND SMI crosses above SignalLine
Short: SMI[1] >= Alert2AboveLevel AND SMI[1] >= DynamicZoneBottom AND SMI[1] <= DynamicZoneTop AND SMI crosses below SignalLine
Long: SMIErgodicHistogram >= 0
Short: SMIErgodicHistogram < 0
Long: SMI >= SignalLine
Short: SMI < SignalLine
Long: PivotLowConfirmed AND Low[DivergenceRightBars] < ValueWhen(PivotLowConfirmed, Low[DivergenceRightBars], 1) AND DivergenceOscillator[DivergenceRightBars] > ValueWhen(PivotLowConfirmed, DivergenceOscillator[DivergenceRightBars], 1) AND DivergenceRangeMin <= BarsSince(PivotLowConfirmed[1]) <= DivergenceRangeMax
Long: PivotLowConfirmed AND Low[DivergenceRightBars] > ValueWhen(PivotLowConfirmed, Low[DivergenceRightBars], 1) AND DivergenceOscillator[DivergenceRightBars] < ValueWhen(PivotLowConfirmed, DivergenceOscillator[DivergenceRightBars], 1) AND DivergenceRangeMin <= BarsSince(PivotLowConfirmed[1]) <= DivergenceRangeMax
Short: PivotHighConfirmed AND High[DivergenceRightBars] > ValueWhen(PivotHighConfirmed, High[DivergenceRightBars], 1) AND DivergenceOscillator[DivergenceRightBars] < ValueWhen(PivotHighConfirmed, DivergenceOscillator[DivergenceRightBars], 1) AND DivergenceRangeMin <= BarsSince(PivotHighConfirmed[1]) <= DivergenceRangeMax
Short: PivotHighConfirmed AND High[DivergenceRightBars] < ValueWhen(PivotHighConfirmed, High[DivergenceRightBars], 1) AND DivergenceOscillator[DivergenceRightBars] > ValueWhen(PivotHighConfirmed, DivergenceOscillator[DivergenceRightBars], 1) AND DivergenceRangeMin <= BarsSince(PivotHighConfirmed[1]) <= DivergenceRangeMax
Long: TrendSeries > PivotHighLine + TrendBreakoutDifference holds for the first time since PivotHighLine was formed
Short: TrendSeries < PivotLowLine - TrendBreakoutDifference holds for the first time since PivotLowLine was formed
Long: SMI crosses above DynamicZoneCenter
Short: SMI crosses below DynamicZoneCenter