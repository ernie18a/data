Calculation: Score(V, S, D, E, age) = (V > Vh ? Pvh : V > Vl ? Pvl : 0) + (S ? Ps : 0) + (D > Dh ? Pdh : D > Dl ? Pdl : 0) + (E > Eh ? Peh : E > El ? Pel : 0) + (age < Ga ? Pga : age < Gb ? Pgb : 0), with Vh > Vl, Dh > Dl, Eh > El, Ga < Gb
Calculation: AtrPercentile = (ATR(A) - Lowest(ATR(A), Qn)) / (Highest(ATR(A), Qn) - Lowest(ATR(A), Qn)) * 100
Calculation: RegimeOK = AtrPercentile < Ql OR AtrPercentile > Qh, with Ql < Qh
Calculation: InSession = bar open time >= S1 AND bar open time < S2 AND weekday of bar in SD
Calculation: NewT1 = open time of the T1 bar still forming differs from its value on the previous chart bar
Calculation: VWAP = VWAP(HLC3, Volume), restarted on each bar where NewT1 is true
Calculation: VolRel = Volume / SMA(Volume, Vn)
Calculation: DemandZone = PivotLow(Low, L, L) is confirmed on this bar AND Highest(High, L) - Low[L] > Kd * ATR(A) AND Score(Vol, Sw, Dv, Ef, 0) >= M, where Vol = VolRel[L], Sw = Low[L] <= Lowest(Low, Sn)[L+1], Dv = abs(Low[L] - VWAP[L]) / ATR(A), Ef = EfficiencyRatio(Close, L); zone low = Low[L], zone high = Low[L] + Zt * ATR(A)
Calculation: SupplyZone = PivotHigh(High, L, L) is confirmed on this bar AND High[L] - Lowest(Low, L) > Kd * ATR(A) AND Score(Vol, Sw, Dv, Ef, 0) >= M, where Vol = VolRel[L], Sw = High[L] >= Highest(High, Sn)[L+1], Dv = abs(High[L] - VWAP[L]) / ATR(A), Ef = EfficiencyRatio(Close, L); zone high = High[L], zone low = High[L] - Zt * ATR(A)
Calculation: Touched = for demand zones: (created on this bar OR Alive[1]) AND Low < zone high AND Close > zone low; for supply zones: (created on this bar OR Alive[1]) AND High > zone low AND Close < zone high
Calculation: Decay = MAX(EXP(-(bars since last touch) / Hd), Fd) if Db is on, else 1; last touch = most recent earlier bar where Touched was true, or the pivot bar if none
Calculation: ZoneScore = Score(Vol, Sw, Dv, Ef, bars since pivot bar) * Decay, with Vol, Sw, Dv, Ef stored at zone creation
Calculation: Alive = (created on this bar OR Alive[1]) AND NOT (demand zone: Close < zone low; supply zone: Close > zone high) AND ZoneScore >= Rf AND bars since pivot bar <= Amax
Calculation: TopZone = the zone with the greatest ZoneScore among zones where Touched is true; ties go to the earliest created zone
Calculation: PenLong = (TopZone zone high - Low) / (TopZone zone high - TopZone zone low)
Calculation: PenShort = (High - TopZone zone low) / (TopZone zone high - TopZone zone low)
Calculation: LongSlotFree = one-trade guard Og is off OR no Long entry on or after the most recent NewT1 bar
Calculation: ShortSlotFree = one-trade guard Og is off OR no Short entry on or after the most recent NewT1 bar
Long: DemandZone
Short: SupplyZone
Long: TopZone side is demand AND ZoneScore of TopZone >= M AND RegimeOK AND InSession AND LongSlotFree AND no position is open AND close > open AND PenLong < Pen
Short: TopZone side is supply AND ZoneScore of TopZone >= M AND RegimeOK AND InSession AND ShortSlotFree AND no position is open AND close < open AND PenShort < Pen
Calculation: LongStop = TopZone zone low - Sb * ATR(A), evaluated on the entry bar
Calculation: LongTarget = entry price + Rr * (entry price - LongStop)
Calculation: LongBreakeven = on some bar from the entry bar through the previous bar, High > entry price + Kb * ATR(A)
Exit: Long, Low <= LongStop OR High >= LongTarget OR (LongBreakeven AND Low <= entry price)
Calculation: ShortStop = TopZone zone high + Sb * ATR(A), evaluated on the entry bar
Calculation: ShortTarget = entry price - Rr * (ShortStop - entry price)
Calculation: ShortBreakeven = on some bar from the entry bar through the previous bar, Low < entry price - Kb * ATR(A)
Exit: Short, High >= ShortStop OR Low <= ShortTarget OR (ShortBreakeven AND High >= entry price)