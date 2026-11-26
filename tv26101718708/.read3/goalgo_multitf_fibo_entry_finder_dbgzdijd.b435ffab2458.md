Calculation: MomSign = +1 if MACD histogram(close, fast, slow, signal) > 0; -1 if < 0; otherwise MomSign[1]
Calculation: BullRunHigh = highest high of the current run of bars with MomSign = +1; undefined otherwise
Calculation: BearRunLow = lowest low of the current run of bars with MomSign = -1; undefined otherwise
Calculation: LegTop = BullRunHigh[1] if MomSign[1] = +1 and MomSign = -1; otherwise LegTop[1]
Calculation: LegBottom = BearRunLow[1] if MomSign[1] = -1 and MomSign = +1; otherwise LegBottom[1]
Calculation: TopLevel = max(high, BullRunHigh[1]) if MomSign[1] = +1 and MomSign = -1; otherwise TopLevel[1]
Calculation: BottomLevel = min(low, BearRunLow[1]) if MomSign[1] = -1 and MomSign = +1; otherwise BottomLevel[1]
Calculation: BuyAlertDepth = 0 if LegTop or LegBottom is undefined or low > LegTop - (LegTop - LegBottom) * r1; otherwise max(BuyAlertDepth[1], largest i such that low <= LegTop - (LegTop - LegBottom) * r_i), with r1 < r2 < r3 < r4
Calculation: SellAlertDepth = 0 if LegTop or LegBottom is undefined or high < LegBottom + (LegTop - LegBottom) * r1; otherwise max(SellAlertDepth[1], largest i such that high >= LegBottom + (LegTop - LegBottom) * r_i)
Calculation: HTFTop = LegTop(T1 bars)[1], read at the last completed T1 bar
Calculation: HTFBottom = LegBottom(T1 bars)[1], read at the last completed T1 bar
Calculation: Bull = LegBottom > HTFBottom
Calculation: Bear = LegTop < HTFTop
Calculation: HTFState = +1 if Bull; otherwise -1 if Bear; otherwise 0
Calculation: Overlap = LegBottom <= HTFTop AND LegTop >= HTFBottom
Long: HTFState = +1 AND HTFState[1] != +1
Short: HTFState = -1 AND HTFState[1] != -1
Long: Overlap AND Bull
Short: Overlap AND Bear
Long: the latest change of MomSign was from +1 to -1 AND LegBottom is defined
Short: the latest change of MomSign was from -1 to +1 AND LegTop is defined
Long: BuyAlertDepth > BuyAlertDepth[1]
Short: SellAlertDepth > SellAlertDepth[1]
Long: MomSign[1] = +1 AND MomSign = -1 AND (TopLevel[1] is undefined OR TopLevel > TopLevel[1])
Short: MomSign[1] = +1 AND MomSign = -1 AND TopLevel[1] is defined AND TopLevel <= TopLevel[1]
Long: MomSign[1] = -1 AND MomSign = +1 AND BottomLevel[1] is defined AND BottomLevel >= BottomLevel[1]
Short: MomSign[1] = -1 AND MomSign = +1 AND (BottomLevel[1] is undefined OR BottomLevel < BottomLevel[1])