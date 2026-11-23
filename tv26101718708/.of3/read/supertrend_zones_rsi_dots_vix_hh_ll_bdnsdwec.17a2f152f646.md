Calculation: SupertrendDirection = Supertrend(high, low, close, Supertrend factor, Supertrend ATR length) direction
Calculation: VolatilityIndexDirection = Supertrend(volatility index high, volatility index low, volatility index close, volatility Supertrend factor, volatility Supertrend ATR length) direction
Calculation: Rsi = RSI(close, rsi length)
Calculation: Signal = Rsi when the raw signal source is selected, otherwise MA(Rsi, smoothing length, smoothing type)
Calculation: RsiPivotLow = PivotLow(Rsi, divergence left bars, divergence right bars)
Calculation: RsiPivotHigh = PivotHigh(Rsi, divergence left bars, divergence right bars)
Calculation: InDivergenceRange(cond) = divergence range lower <= BarsSince(cond) <= divergence range upper
Calculation: StructureHigh = PivotHigh(high, structure left bars, structure right bars)
Calculation: StructureLow = PivotLow(low, structure left bars, structure right bars)
Calculation: HigherHigh = StructureHigh is confirmed AND StructureHigh > ValueWhen(StructureHigh is confirmed, StructureHigh, 1)
Calculation: LowerLow = StructureLow is confirmed AND StructureLow < ValueWhen(StructureLow is confirmed, StructureLow, 1)
Calculation: HigherLow = StructureLow is confirmed AND NOT LowerLow
Calculation: LowerHigh = StructureHigh is confirmed AND NOT HigherHigh
Calculation: LastLabel = the type (higher high, higher low, lower high or lower low) of the most recent earlier bar on which HigherHigh, HigherLow, LowerHigh or LowerLow is true
Long: SupertrendDirection < 0
Short: SupertrendDirection > 0
Long: SupertrendDirection crosses below 0
Short: SupertrendDirection crosses above 0
Long: SupertrendDirection < 0 AND Signal crosses above mid level
Short: SupertrendDirection > 0 AND Signal crosses below mid level
Long: VolatilityIndexDirection < 0
Short: VolatilityIndexDirection > 0
Long: RsiPivotLow is confirmed AND Rsi[divergence right bars] > ValueWhen(RsiPivotLow is confirmed, Rsi[divergence right bars], 1) AND low[divergence right bars] < ValueWhen(RsiPivotLow is confirmed, low[divergence right bars], 1) AND InDivergenceRange(RsiPivotLow is confirmed[1])
Short: RsiPivotHigh is confirmed AND Rsi[divergence right bars] < ValueWhen(RsiPivotHigh is confirmed, Rsi[divergence right bars], 1) AND high[divergence right bars] > ValueWhen(RsiPivotHigh is confirmed, high[divergence right bars], 1) AND InDivergenceRange(RsiPivotHigh is confirmed[1])
Long: HigherLow
Long: HigherHigh
Long: HigherHigh AND (LastLabel is lower low OR LastLabel is lower high)
Short: LowerHigh
Short: LowerLow
Short: LowerLow AND (LastLabel is higher low OR LastLabel is higher high)