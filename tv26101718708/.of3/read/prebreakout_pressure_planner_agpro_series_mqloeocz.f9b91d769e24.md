Calculation: RangeHigh = Highest(high[1], Lr)
Calculation: RangeLow = Lowest(low[1], Lr)
Calculation: AvgTR = ATR(La)
Calculation: Loc = Clamp((close - RangeLow) / (RangeHigh - RangeLow), 0, 1)
Calculation: Body = Abs(close - open) / (high - low)
Calculation: Bcl = (close - low) / (high - low)
Calculation: BullCandle = close >= open ? cBody*Body + cLoc*Bcl : cOpp*Bcl
Calculation: BearCandle = close <= open ? cBody*Body + cLoc*(1 - Bcl) : cOpp*(1 - Bcl)
Calculation: BullRaw = rSlope*Clamp(sMid + sScale*(LinReg(low, Ls, 0) - LinReg(low, Ls, 1))/AvgTR, 0, 100) + rClose*100*Loc + rCandle*BullCandle
Calculation: BearRaw = rSlope*Clamp(sMid - sScale*(LinReg(high, Ls, 0) - LinReg(high, Ls, 1))/AvgTR, 0, 100) + rClose*100*(1 - Loc) + rCandle*BearCandle
Calculation: Rv = volume / SMA(volume, Lv)
Calculation: VolScore = Clamp(Clamp((Rv - vFloor)/Max(Rs - vFloor, vSpan)*vLevelScale, 0, vLevelCap) + Clamp((Rv - Rv[Lq])*vSlopeScale, -vSlopeCap, vSlopeCap) + vBase, 0, 100)
Calculation: DirCandle = BullRaw >= BearRaw ? BullCandle : BearCandle
Calculation: Score = Clamp(wComp*Clamp(100 - ((RangeHigh - RangeLow)/AvgTR - cTight)/Max(cBad - cTight, cFloor)*100, 0, 100) + wSide*Max(BullRaw, BearRaw) + wVol*VolScore + wCandle*DirCandle + wClose*100*(BullRaw >= BearRaw ? Loc : 1 - Loc), 0, 100)
Calculation: UpperProbe = RangeHigh > RangeLow AND high > RangeHigh + Bt*AvgTR AND close <= RangeHigh
Calculation: LowerProbe = RangeHigh > RangeLow AND low < RangeLow - Bt*AvgTR AND close >= RangeLow
Calculation: Fakeout = (UpperProbe OR LowerProbe) AND (fCandle*(100 - DirCandle) + fVol*(100 - VolScore) + ((RangeHigh - RangeLow)/AvgTR > cBad ? fWide : 0) + fProbe >= Tf)
Calculation: UpperTrig = RangeHigh > RangeLow AND close > RangeHigh + Bt*AvgTR
Calculation: LowerTrig = RangeHigh > RangeLow AND close < RangeLow - Bt*AvgTR
Calculation: TrigAny = UpperTrig OR LowerTrig
Calculation: BullState = RangeHigh > RangeLow AND close <= RangeHigh AND close >= RangeLow AND NOT Fakeout AND BullRaw - BearRaw >= Te AND Score >= Tp
Calculation: BearState = RangeHigh > RangeLow AND close <= RangeHigh AND close >= RangeLow AND NOT Fakeout AND BearRaw - BullRaw >= Te AND Score >= Tp
Long: BullRaw - BearRaw >= Te
Long: BullState
Long: BullState AND Score >= Ta AND NOT BullState[1]
Long: UpperTrig AND NOT Fakeout AND Score >= Tw
Long: UpperTrig AND Score >= Tw AND NOT TrigAny[1]
Short: BearRaw - BullRaw >= Te
Short: BearState
Short: BearState AND Score >= Ta AND NOT BearState[1]
Short: LowerTrig AND NOT Fakeout AND Score >= Tw
Short: LowerTrig AND Score >= Tw AND NOT TrigAny[1]
Exit: long, BullRaw - BearRaw >= Te AND RangeHigh > RangeLow AND close < RangeLow - Bi*AvgTR
Exit: short, BearRaw - BullRaw >= Te AND RangeHigh > RangeLow AND close > RangeHigh + Bi*AvgTR