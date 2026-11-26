Calculation: FastEMA(Tk) = EMA(close, F, Tk, last completed bar), for Tk in {T1, T2, T3}
Calculation: SlowEMA(Tk) = EMA(close, S, Tk, last completed bar), where S is longer than F, for Tk in {T1, T2, T3}
Calculation: Atr(Tk) = ATR(A, Tk, last completed bar)
Calculation: EmaSlope(Tk) = (FastEMA(Tk) - FastEMA(Tk)[N]) / max(Atr(Tk), tick)
Calculation: LastPivotHigh(Tk) = most recent non-na pivot high of high with L bars on each side, on Tk bars, last completed bar
Calculation: LastPivotLow(Tk) = most recent non-na pivot low of low with L bars on each side, on Tk bars, last completed bar
Calculation: BosUp(Tk) = close(Tk) > LastPivotHigh(Tk), last completed Tk bar
Calculation: BosDn(Tk) = close(Tk) < LastPivotLow(Tk), last completed Tk bar
Calculation: ImpUp(Tk) = close(Tk) > open(Tk) AND close(Tk) - open(Tk) >= B * max(high(Tk) - low(Tk), tick) AND max(high(Tk) - low(Tk), tick) >= I * Atr(Tk) AND close(Tk) > high(Tk)[1], last completed Tk bar
Calculation: ImpDn(Tk) = close(Tk) < open(Tk) AND open(Tk) - close(Tk) >= B * max(high(Tk) - low(Tk), tick) AND max(high(Tk) - low(Tk), tick) >= I * Atr(Tk) AND close(Tk) < low(Tk)[1], last completed Tk bar
Calculation: FvgUp(Tk) = low(Tk) > high(Tk)[2] AND low(Tk) - high(Tk)[2] > G * Atr(Tk), last completed Tk bar
Calculation: FvgDn(Tk) = high(Tk) < low(Tk)[2] AND low(Tk)[2] - high(Tk) > G * Atr(Tk), last completed Tk bar
Calculation: TrendBullPts(Tk) = wt_CF * [close(Tk) > FastEMA(Tk)] + wt_FS * [FastEMA(Tk) > SlowEMA(Tk)] + (wt_SH if EmaSlope(Tk) > s_k, else wt_SL if EmaSlope(Tk) > 0, else 0) + wt_BOS * [BosUp(Tk)] + wt_IMP * [ImpUp(Tk)] + wt_FVG * [FvgUp(Tk)], for Tk in {T1, T2}, with s_1 the slope threshold for T1 and s_2 for T2
Calculation: TrendBearPts(Tk) = wt_CF * [close(Tk) < FastEMA(Tk)] + wt_FS * [FastEMA(Tk) < SlowEMA(Tk)] + (wt_SH if EmaSlope(Tk) < -s_k, else wt_SL if EmaSlope(Tk) < 0, else 0) + wt_BOS * [BosDn(Tk)] + wt_IMP * [ImpDn(Tk)] + wt_FVG * [FvgDn(Tk)], for Tk in {T1, T2}, with s_1 for T1 and s_2 for T2
Calculation: IntradayBullPts = wm_CF * [close(T3) > FastEMA(T3)] + wm_FS * [FastEMA(T3) > SlowEMA(T3)] + wm_BOS * [BosUp(T3)] + wm_IMP * [ImpUp(T3)] + wm_FVG * [FvgUp(T3)] + wm_EXP * [ExplUp]
Calculation: IntradayBearPts = wm_CF * [close(T3) < FastEMA(T3)] + wm_FS * [FastEMA(T3) < SlowEMA(T3)] + wm_BOS * [BosDn(T3)] + wm_IMP * [ImpDn(T3)] + wm_FVG * [FvgDn(T3)] + wm_EXP * [ExplDn]
Calculation: BullDir1 = TrendBullPts(T1) >= TrendBearPts(T1) + M
Calculation: BearDir1 = TrendBearPts(T1) >= TrendBullPts(T1) + M
Calculation: BullDir2 = TrendBullPts(T2) >= TrendBearPts(T2) + M
Calculation: BearDir2 = TrendBearPts(T2) >= TrendBullPts(T2) + M
Calculation: BullDir3 = IntradayBullPts >= IntradayBearPts + M
Calculation: BearDir3 = IntradayBearPts >= IntradayBullPts + M
Calculation: BullDirCount = [BullDir1] + [BullDir2] + [BullDir3]
Calculation: BearDirCount = [BearDir1] + [BearDir2] + [BearDir3]
Calculation: BullScore = min(max(w1_CF * [close(T1) > FastEMA(T1)] + w1_FS * [FastEMA(T1) > SlowEMA(T1)] + (w1_SH if EmaSlope(T1) > s_1, else w1_SL if EmaSlope(T1) > 0, else 0) + w1_BOS * [BosUp(T1)] + w1_PH * [close(T1) > LastPivotHigh(T1)] + w1_FVG * [FvgUp(T1)] + w2_CF * [close(T2) > FastEMA(T2)] + w2_FS * [FastEMA(T2) > SlowEMA(T2)] + (w2_SH if EmaSlope(T2) > s_2, else w2_SL if EmaSlope(T2) > 0, else 0) + w2_BOS * [BosUp(T2)] + w2_IMP * [ImpUp(T2)] + w2_FVG * [FvgUp(T2)] + w3_CF * [close(T3) > FastEMA(T3)] + w3_FS * [FastEMA(T3) > SlowEMA(T3)] + w3_BOS * [BosUp(T3)] + w3_IMP * [ImpUp(T3)] + w3_FVG * [FvgUp(T3)] + w3_EXP * [ExplUp] + wl_SWP * [RecentLowSweep] + wl_AFT * [BullEventAfterLowSweep] + wl_TGT * [CloseBelowHighs] + wl_DAY * [LongBias(T5)] + wl_SWD * [LowTaken(T5)] - wp * [RecentBearImb], 0), 100)
Calculation: BearScore = min(max(w1_CF * [close(T1) < FastEMA(T1)] + w1_FS * [FastEMA(T1) < SlowEMA(T1)] + (w1_SH if EmaSlope(T1) < -s_1, else w1_SL if EmaSlope(T1) < 0, else 0) + w1_BOS * [BosDn(T1)] + w1_PH * [close(T1) < LastPivotLow(T1)] + w1_FVG * [FvgDn(T1)] + w2_CF * [close(T2) < FastEMA(T2)] + w2_FS * [FastEMA(T2) < SlowEMA(T2)] + (w2_SH if EmaSlope(T2) < -s_2, else w2_SL if EmaSlope(T2) < 0, else 0) + w2_BOS * [BosDn(T2)] + w2_IMP * [ImpDn(T2)] + w2_FVG * [FvgDn(T2)] + w3_CF * [close(T3) < FastEMA(T3)] + w3_FS * [FastEMA(T3) < SlowEMA(T3)] + w3_BOS * [BosDn(T3)] + w3_IMP * [ImpDn(T3)] + w3_FVG * [FvgDn(T3)] + w3_EXP * [ExplDn] + wl_SWP * [RecentHighSweep] + wl_AFT * [BearEventAfterHighSweep] + wl_TGT * [CloseAboveLows] + wl_DAY * [ShortBias(T5)] + wl_SWD * [HighTaken(T5)] - wp * [RecentBullImb], 0), 100)
Calculation: BullShare = round(100 * BullScore / max(BullScore + BearScore, 1))
Calculation: BearShare = round(100 * BearScore / max(BullScore + BearScore, 1))
Calculation: Recent(X) = barssince(X) <= W, with X evaluated on T3 bars, last completed bar
Calculation: PrevHigh(Tp) = highest high of T3 bars in the previous Tp period, for Tp in {T5, T6}
Calculation: PrevLow(Tp) = lowest low of T3 bars in the previous Tp period, for Tp in {T5, T6}
Calculation: CurHigh(T5) = highest high of T3 bars from the start of the current T5 period through the last completed T3 bar
Calculation: CurLow(T5) = lowest low of T3 bars from the start of the current T5 period through the last completed T3 bar
Calculation: CurOpen(T5) = open of the first T3 bar in the current T5 period
Calculation: Center(T5) = (PrevHigh(T5) + PrevLow(T5)) / 2
Calculation: LongBias(T5) = CurOpen(T5) > Center(T5) AND CurHigh(T5) <= PrevHigh(T5)
Calculation: ShortBias(T5) = CurOpen(T5) < Center(T5) AND CurLow(T5) >= PrevLow(T5)
Calculation: HighTaken(T5) = CurHigh(T5) > PrevHigh(T5)
Calculation: LowTaken(T5) = CurLow(T5) < PrevLow(T5)
Calculation: HighSweep = on T3 bars, last completed bar: (high(T3) > LastPivotHigh(T3) AND close(T3) < LastPivotHigh(T3)) OR (high(T3) > PrevHigh(T5) AND close(T3) < PrevHigh(T5)) OR (high(T3) > PrevHigh(T6) AND close(T3) < PrevHigh(T6))
Calculation: LowSweep = on T3 bars, last completed bar: (low(T3) < LastPivotLow(T3) AND close(T3) > LastPivotLow(T3)) OR (low(T3) < PrevLow(T5) AND close(T3) > PrevLow(T5)) OR (low(T3) < PrevLow(T6) AND close(T3) > PrevLow(T6))
Calculation: RecentHighSweep = Recent(HighSweep)
Calculation: RecentLowSweep = Recent(LowSweep)
Calculation: CloseBelowHighs = close(T3) < LastPivotHigh(T3) OR close(T3) < PrevHigh(T5) OR close(T3) < PrevHigh(T6), last completed T3 bar
Calculation: CloseAboveLows = close(T3) > LastPivotLow(T3) OR close(T3) > PrevLow(T5) OR close(T3) > PrevLow(T6), last completed T3 bar
Calculation: BullEvent = ImpUp(T3) OR BosUp(T3) OR FvgUp(T3)
Calculation: BearEvent = ImpDn(T3) OR BosDn(T3) OR FvgDn(T3)
Calculation: RecentBullEvent = Recent(BullEvent)
Calculation: RecentBearEvent = Recent(BearEvent)
Calculation: RecentBullImb = Recent(ImpUp(T3) OR FvgUp(T3))
Calculation: RecentBearImb = Recent(ImpDn(T3) OR FvgDn(T3))
Calculation: BullEventAfterLowSweep = RecentLowSweep AND RecentBullEvent AND barssince(BullEvent) <= barssince(LowSweep)
Calculation: BearEventAfterHighSweep = RecentHighSweep AND RecentBearEvent AND barssince(BearEvent) <= barssince(HighSweep)
Calculation: ExplUp = (BosUp(T3) OR ImpUp(T3)) AND RecentBullImb AND NOT RecentHighSweep
Calculation: ExplDn = (BosDn(T3) OR ImpDn(T3)) AND RecentBearImb AND NOT RecentLowSweep
Calculation: RangePos = Stochastic %K(close, high, low, R, T3, last completed bar)
Calculation: ExtBull(s) = [close(s) > EMA(close(s), Ex, T4, last completed bar) AND ROC(close(s), Rx, T4, last completed bar) > 0], for s in {US dollar index, US 10-year yield, US 2-year yield}
Calculation: ExtBear(s) = [close(s) < EMA(close(s), Ex, T4, last completed bar) AND ROC(close(s), Rx, T4, last completed bar) < 0], for s in {US dollar index, US 10-year yield, US 2-year yield}
Calculation: ExtBullCount = ExtBull(US dollar index) + ExtBull(US 10-year yield) + ExtBull(US 2-year yield)
Calculation: ExtBearCount = ExtBear(US dollar index) + ExtBear(US 10-year yield) + ExtBear(US 2-year yield)
Long: BullShare > BearShare
Short: BearShare > BullShare
Long: BullDir1 AND BullDir2 AND BullDir3
Short: BearDir1 AND BearDir2 AND BearDir3
Long: BullDir1
Long: BullDir2
Long: BullDir3
Short: BearDir1
Short: BearDir2
Short: BearDir3
Long: BullDirCount = 2 AND NOT (BullDir2 AND (BearDir1 OR BearDir3))
Short: BearDirCount = 2 AND NOT (BearDir2 AND (BullDir1 OR BullDir3))
Long: RecentLowSweep AND NOT RecentHighSweep
Short: RecentHighSweep AND NOT RecentLowSweep
Long: RecentBullImb AND NOT RecentBearImb
Short: RecentBearImb AND NOT RecentBullImb
Long: RangePos <= D
Short: RangePos >= P
Long: ExtBearCount >= 2 AND ExtBearCount > ExtBullCount
Short: ExtBullCount >= 2 AND ExtBullCount > ExtBearCount