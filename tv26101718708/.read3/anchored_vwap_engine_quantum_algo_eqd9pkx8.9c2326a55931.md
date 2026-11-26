Calculation: VWSD = sqrt(max(AnchoredVWAP(hlc3^2, volume, primary anchor) - AnchoredVWAP(hlc3, volume, primary anchor)^2, 0))
Calculation: LowerBand = AnchoredVWAP(hlc3, volume, primary anchor) - band multiplier * VWSD
Calculation: UpperBand = AnchoredVWAP(hlc3, volume, primary anchor) + band multiplier * VWSD
Calculation: SweepSide = 1 if low < last confirmed PivotLow(low, swing pivot length, swing pivot length) AND close > that PivotLow AND that PivotLow is not yet swept; -1 if high > last confirmed PivotHigh(high, swing pivot length, swing pivot length) AND close < that PivotHigh AND that PivotHigh is not yet swept; otherwise the previous SweepSide
Calculation: BarsSinceSignal = bars since the most recent earlier bar on which the Long or Short band-rejection condition held
Long: low <= LowerBand AND close > LowerBand AND close < AnchoredVWAP(hlc3, volume, primary anchor) AND BarsSinceSignal >= signal cooldown
Short: high >= UpperBand AND close < UpperBand AND close > AnchoredVWAP(hlc3, volume, primary anchor) AND BarsSinceSignal >= signal cooldown
Long: close crosses above AnchoredVWAP(hlc3, volume, primary anchor)
Short: close crosses below AnchoredVWAP(hlc3, volume, primary anchor)
Long: SweepSide = 1
Short: SweepSide = -1
Long: close > AnchoredVWAP(hlc3, volume, anchor)
Short: close <= AnchoredVWAP(hlc3, volume, anchor)