Calculation: SupplyPivot = if PivotHigh(high, PivotBars, PivotBars) is na then SupplyPivot[1] else PivotHigh(high, PivotBars, PivotBars)
Calculation: SupplyZoneAge = BarsSince(PivotHigh(high, PivotBars, PivotBars) is not na)
Calculation: SupplyZoneTop = if SupplyZoneAge = 0 then (if abs(SupplyPivot - SupplyPivot[1]) <= ATR(AtrPeriod) * ClusterAtrMult then average(SupplyPivot, SupplyPivot[1]) else SupplyPivot) else SupplyZoneTop[1]
Calculation: SupplyZoneBottom = if SupplyZoneAge = 0 then SupplyZoneTop - ATR(AtrPeriod) * ZoneAtrMult else SupplyZoneBottom[1]
Calculation: SupplyReleased = if SupplyZoneAge = 0 then false else (SupplyReleased[1] OR (close > SupplyZoneTop AND BodyQuality >= MinBodyQuality AND SupplyZoneAge >= MinZoneAge))
Calculation: DemandPivot = if PivotLow(low, PivotBars, PivotBars) is na then DemandPivot[1] else PivotLow(low, PivotBars, PivotBars)
Calculation: DemandZoneAge = BarsSince(PivotLow(low, PivotBars, PivotBars) is not na)
Calculation: DemandZoneBottom = if DemandZoneAge = 0 then (if abs(DemandPivot - DemandPivot[1]) <= ATR(AtrPeriod) * ClusterAtrMult then average(DemandPivot, DemandPivot[1]) else DemandPivot) else DemandZoneBottom[1]
Calculation: DemandZoneTop = if DemandZoneAge = 0 then DemandZoneBottom + ATR(AtrPeriod) * ZoneAtrMult else DemandZoneTop[1]
Calculation: DemandReleased = if DemandZoneAge = 0 then false else (DemandReleased[1] OR (close < DemandZoneBottom AND BodyQuality >= MinBodyQuality AND DemandZoneAge >= MinZoneAge))
Calculation: BodyQuality = abs(close - open) / (high - low)
Long: close > SupplyZoneTop AND BodyQuality >= MinBodyQuality AND SupplyZoneAge >= MinZoneAge AND NOT SupplyReleased[1]
Long: SupplyReleased[1] AND SupplyZoneAge >= 1 AND low <= SupplyZoneTop AND close >= SupplyZoneBottom
Short: close < DemandZoneBottom AND BodyQuality >= MinBodyQuality AND DemandZoneAge >= MinZoneAge AND NOT DemandReleased[1]
Short: DemandReleased[1] AND DemandZoneAge >= 1 AND high >= DemandZoneBottom AND close <= DemandZoneTop
Short: NOT SupplyReleased AND high >= SupplyZoneBottom AND low <= SupplyZoneTop
Long: NOT DemandReleased AND high >= DemandZoneBottom AND low <= DemandZoneTop