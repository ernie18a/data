Calculation: VarianceRiskPremium = implied volatility index close - HistoricalVolatility(close, realized window, annualization factor) in percent
Calculation: VRPOscillator = EMA((VarianceRiskPremium - SMA(VarianceRiskPremium, normalization window)) / STDEV(VarianceRiskPremium, normalization window), smoothing length)
Calculation: LastLowPivotOsc = PivotLow(VRPOscillator, divergence pivot length, divergence pivot length) if not NA, else LastLowPivotOsc[1]
Calculation: LastLowPivotPrice = Low[divergence pivot length] if PivotLow(VRPOscillator, divergence pivot length, divergence pivot length) is not NA, else LastLowPivotPrice[1]
Calculation: LastHighPivotOsc = PivotHigh(VRPOscillator, divergence pivot length, divergence pivot length) if not NA, else LastHighPivotOsc[1]
Calculation: LastHighPivotPrice = High[divergence pivot length] if PivotHigh(VRPOscillator, divergence pivot length, divergence pivot length) is not NA, else LastHighPivotPrice[1]
Long: VRPOscillator crosses above -stretch band
Long: PivotLow(VRPOscillator, divergence pivot length, divergence pivot length) > LastLowPivotOsc[1] AND Low[divergence pivot length] < LastLowPivotPrice[1]
Long: VRPOscillator <= -extreme band
Short: VRPOscillator crosses below stretch band
Short: PivotHigh(VRPOscillator, divergence pivot length, divergence pivot length) < LastHighPivotOsc[1] AND High[divergence pivot length] > LastHighPivotPrice[1]
Short: VRPOscillator >= extreme band