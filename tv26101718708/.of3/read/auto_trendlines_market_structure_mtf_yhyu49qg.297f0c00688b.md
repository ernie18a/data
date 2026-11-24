Calculation: PivotLen = IF(IsAdaptive, MIN(MAX(INT(100*ATR(AtrLen)/close*PivotMult), PivotMin), PivotMax), FixedLen)
Calculation: ResSlopeAtr = (R2.price - R1.price)/(R2.bar - R1.bar)/ATR(AtrLen), taken on the confirmation bar of R2 and held until the next confirmed pivot high, where R1 and R2 are the previous and latest confirmed PivotHigh(high, PivotLen, PivotLen) and bar = confirmation bar - PivotLen
Calculation: ResBroken = close > R1.price + (R2.price - R1.price)/(R2.bar - R1.bar)*(bar index - R1.bar) + BreakMult*ATR(AtrLen) OR (ResBroken[1] AND NOT PivotHigh(high, PivotLen, PivotLen) confirmed on this bar)
Calculation: ResActive = two confirmed pivot highs exist AND NOT ResBroken
Calculation: SupSlopeAtr = (S2.price - S1.price)/(S2.bar - S1.bar)/ATR(AtrLen), taken on the confirmation bar of S2 and held until the next confirmed pivot low, where S1 and S2 are the previous and latest confirmed PivotLow(low, PivotLen, PivotLen) and bar = confirmation bar - PivotLen
Calculation: SupBroken = close < S1.price + (S2.price - S1.price)/(S2.bar - S1.bar)*(bar index - S1.bar) - BreakMult*ATR(AtrLen) OR (SupBroken[1] AND NOT PivotLow(low, PivotLen, PivotLen) confirmed on this bar)
Calculation: SupActive = two confirmed pivot lows exist AND NOT SupBroken
Calculation: TrendBull = (ResActive AND SupActive AND ResSlopeAtr > SlopeThr AND SupSlopeAtr > SlopeThr) OR (SupActive AND NOT ResActive AND SupSlopeAtr > SlopeThr) OR (ResActive AND NOT SupActive AND ResSlopeAtr > SlopeThr)
Calculation: TrendBear = (ResActive AND SupActive AND ResSlopeAtr < -SlopeThr AND SupSlopeAtr < -SlopeThr) OR (SupActive AND NOT ResActive AND SupSlopeAtr < -SlopeThr) OR (ResActive AND NOT SupActive AND ResSlopeAtr < -SlopeThr)
Long: TrendBull OR (ResActive AND NOT SupActive) OR (SupActive AND NOT ResActive)
Long: ResBroken AND NOT ResBroken[1]
Short: TrendBear
Short: SupBroken AND NOT SupBroken[1]
Long: TrendBull(T1, last completed bar)[1]
Short: TrendBear(T1, last completed bar)[1]
Long: TrendBull(T2, last completed bar)[1]
Short: TrendBear(T2, last completed bar)[1]
Long: TrendBull(T3, last completed bar)[1]
Short: TrendBear(T3, last completed bar)[1]