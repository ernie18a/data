Calculation: UpCount = weighted count of T1 bars in the last completed chart bar with close > open, each weighted W in the later half of the chart bar and 1 otherwise
Calculation: DownCount = weighted count of T1 bars in the last completed chart bar with close < open, each weighted W in the later half of the chart bar and 1 otherwise
Calculation: TotalCount = weighted count of all T1 bars in the last completed chart bar, each weighted W in the later half of the chart bar and 1 otherwise
Calculation: Ratio = (UpCount + DownCount) / TotalCount
Calculation: AvgBal = EMA(UpCount, avgLookback) - EMA(DownCount, avgLookback)
Calculation: MomBal = RSI((EMA(UpCount, avgLookback) - SMA(UpCount, 2 * avgLookback)) - (EMA(DownCount, avgLookback) - SMA(DownCount, 2 * avgLookback)), momLookback) - 50
Calculation: AllBal = (UpCount > DownCount) + (AvgBal > 0) + (MomBal > 0) - (UpCount < DownCount) - (AvgBal < 0) - (MomBal < 0)
Calculation: MarkerBias = sum(((AllBal = 3) + (UpCount / TotalCount > R and close > open) + (DivUp(p3)[1] and close > open and not DivDn(p3)) + crosses above(Sig(p4), 0)) - ((AllBal = -3) + (DownCount / TotalCount > R and close <= open) + (DivDn(p3)[1] and close <= open and not DivUp(p3)) + crosses below(Sig(p4), 0)), biasLookback)
Calculation: Sig(p) = selected by p from UpCount - DownCount, AvgBal, MomBal, MarkerBias, AllBal, Balance - (LevelHi + LevelLo) / 2
Calculation: Balance = (selected by pBal from UpCount - DownCount, AvgBal, MomBal, MarkerBias, AllBal, EMA(UpCount, dualLookback)) * (selected by pDamp from 1, Ratio, EMA(Ratio, shorterLookback), EMA(Ratio, longerLookback))
Calculation: DivUp(p) = Sig(p) > 0 and close <= open
Calculation: DivDn(p) = Sig(p) < 0 and close > open
Calculation: DivEvent = DivUp(pDiv) or DivDn(pDiv) or (Ratio < H and neutral-ratio divergence enabled)
Calculation: Reset = DivEvent and not DivEvent[1] and (Breached[1] or Balance > LevelHi[1] or Balance < LevelLo[1])
Calculation: Breached = (Breached[1] or Balance > LevelHi[1] or Balance < LevelLo[1]) and not Reset
Calculation: LevelHi = Balance if Reset, otherwise max(LevelHi[1], Balance) if DivEvent, otherwise LevelHi[1]
Calculation: LevelLo = Balance if Reset, otherwise min(LevelLo[1], Balance) if DivEvent, otherwise LevelLo[1]
Calculation: HState = Balance > LevelHi[1] and not Reset
Calculation: LState = Balance < LevelLo[1] and not Reset
Long: AllBal = 3
Short: AllBal = -3
Long: UpCount / TotalCount > R and close > open
Short: DownCount / TotalCount > R and close <= open
Long: DivUp(p3)[1] and close > open and not DivDn(p3)
Short: DivDn(p3)[1] and close <= open and not DivUp(p3)
Long: crosses above(Sig(p4), 0)
Short: crosses below(Sig(p4), 0)
Long: crosses above(MarkerBias, B)[1]
Short: crosses below(MarkerBias, -B)[1]
Long: HState and not HState[1]
Short: LState and not LState[1]
Long: Sig(pLine) > 0
Short: Sig(pLine) <= 0
Long: Sig(pFill) > 0
Short: Sig(pFill) < 0
Long: Sig(pBar) > 0
Short: Sig(pBar) < 0
Long: Sig(pBg) > 0
Short: Sig(pBg) < 0
Long: UpCount > DownCount
Short: UpCount <= DownCount
Long: AvgBal > 0
Short: AvgBal <= 0
Long: MomBal > 0
Short: MomBal <= 0
Long: AllBal > 0
Short: AllBal <= 0
Long: HState
Short: LState