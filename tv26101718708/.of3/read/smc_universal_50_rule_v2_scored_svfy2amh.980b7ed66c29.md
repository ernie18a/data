Calculation: LastPivotHigh = last non-NA PivotHigh(high, pivot left strength, pivot right strength) on T1 bars, taking the value of the T1 bar still forming
Calculation: LastPivotLow = last non-NA PivotLow(low, pivot left strength, pivot right strength) on T1 bars, taking the value of the T1 bar still forming
Calculation: Equilibrium = (LastPivotHigh + LastPivotLow) / 2
Calculation: AtHigh = abs(close - LastPivotHigh) <= ATR(ATR lookback) * touch tolerance multiple
Calculation: AtLow = abs(close - LastPivotLow) <= ATR(ATR lookback) * touch tolerance multiple
Calculation: AtEquilibrium = abs(close - Equilibrium) <= ATR(ATR lookback) * touch tolerance multiple
Calculation: AtLevel = AtHigh OR AtLow OR AtEquilibrium
Calculation: InPoiZone = MIN(abs(close - LastPivotHigh), abs(close - LastPivotLow), abs(close - Equilibrium)) <= close * POI band percent / 100
Calculation: Premium = close > Equilibrium
Calculation: Discount = close < Equilibrium
Calculation: SweptHigh = high > LastPivotHigh AND close < LastPivotHigh AND open < LastPivotHigh
Calculation: SweptLow = low < LastPivotLow AND close > LastPivotLow AND open > LastPivotLow
Calculation: LongSweep = NOT SweptHigh AND (SweptLow OR (low < Equilibrium AND close > Equilibrium AND open > Equilibrium AND Premium[1]))
Calculation: ShortSweep = SweptHigh OR (NOT SweptLow AND high > Equilibrium AND close < Equilibrium AND open < Equilibrium AND Discount[1])
Calculation: VolumeSpike = volume > SMA(volume, volume lookback) * volume spike multiple
Calculation: LongAbsorption = volume > SMA(volume, volume lookback) * absorption volume multiple AND (min(open, close) - low) / (high - low) >= absorption wick ratio AND (AtLow OR (AtEquilibrium AND Discount[1]))
Calculation: ShortAbsorption = volume > SMA(volume, volume lookback) * absorption volume multiple AND (high - max(open, close)) / (high - low) >= absorption wick ratio AND (AtHigh OR (AtEquilibrium AND Premium[1]))
Calculation: LongEngulf = AtLevel AND close > open AND close[1] < open[1] AND abs(close - open) > abs(close[1] - open[1]) AND ((strict engulfing AND open < close[1] AND close > open[1]) OR (NOT strict engulfing AND open <= close[1] AND close >= open[1] AND (open < close[1] OR close > open[1])))
Calculation: ShortEngulf = AtLevel AND close < open AND close[1] > open[1] AND abs(close - open) > abs(close[1] - open[1]) AND ((strict engulfing AND open > close[1] AND close < open[1]) OR (NOT strict engulfing AND open >= close[1] AND close <= open[1] AND (open > close[1] OR close < open[1])))
Calculation: DeltaSignificance = SMA(volume, volume lookback) * delta significance multiple
Calculation: DeltaSum = if InPoiZone then DeltaSum[1] + (volume if close > open, -volume if close < open, 0 otherwise) else 0
Calculation: LongScore = if AtLevel then (at-level points + (sweep points if LongSweep) + (engulf points if LongEngulf) + (absorption points if LongAbsorption) + (volume spike points if VolumeSpike AND (LongSweep OR LongEngulf OR LongAbsorption)) + (delta alignment points if DeltaSum > DeltaSignificance AND (AtLow OR AtEquilibrium)) + (zone alignment points if Discount)) else 0
Calculation: ShortScore = if AtLevel then (at-level points + (sweep points if ShortSweep) + (engulf points if ShortEngulf) + (absorption points if ShortAbsorption) + (volume spike points if VolumeSpike AND (ShortSweep OR ShortEngulf OR ShortAbsorption)) + (delta alignment points if DeltaSum < -DeltaSignificance AND (AtHigh OR AtEquilibrium)) + (zone alignment points if Premium)) else 0
Calculation: LongSetup = (LongSweep OR LongEngulf OR LongAbsorption) AND LongScore > ShortScore
Calculation: ShortSetup = (ShortSweep OR ShortEngulf OR ShortAbsorption) AND ShortScore > LongScore
Long: LongSetup
Long: LongSetup AND LongScore >= B score threshold AND LongScore >= A score threshold
Long: LongSetup AND LongScore >= B score threshold AND LongScore >= A+ score threshold
Long: LongSweep
Long: LongEngulf
Long: LongAbsorption
Long: close crosses above EMA(close, momentum EMA lookback) AND volume > SMA(volume, momentum volume lookback) * momentum volume multiple
Long: InPoiZone AND DeltaSum > DeltaSignificance AND NOT (LongAbsorption OR ShortAbsorption)
Long: Discount
Short: ShortSetup
Short: ShortSetup AND ShortScore >= B score threshold AND ShortScore >= A score threshold
Short: ShortSetup AND ShortScore >= B score threshold AND ShortScore >= A+ score threshold
Short: ShortSweep
Short: ShortEngulf
Short: ShortAbsorption
Short: close crosses below EMA(close, momentum EMA lookback) AND volume > SMA(volume, momentum volume lookback) * momentum volume multiple
Short: InPoiZone AND DeltaSum < -DeltaSignificance AND NOT (LongAbsorption OR ShortAbsorption)
Short: Premium