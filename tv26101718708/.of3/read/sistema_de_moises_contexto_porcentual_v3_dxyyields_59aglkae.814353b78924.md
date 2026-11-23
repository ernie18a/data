Calculation: FastEMA(T) = EMA(close, shorter lookback, T, last completed bar)
Calculation: SlowEMA(T) = EMA(close, longer lookback, T, last completed bar)
Calculation: LastClose(T) = close of the last completed T bar
Calculation: ATRv(T) = ATR(ATR length, T, last completed bar)
Calculation: Slope(T) = (FastEMA(T) - FastEMA(T)[slope lag]) / ATRv(T), on T bars, last completed bar
Calculation: SwingHigh(T) = latest non-NA pivot high(high, pivot length, pivot length) on T bars, last completed bar
Calculation: SwingLow(T) = latest non-NA pivot low(low, pivot length, pivot length) on T bars, last completed bar
Calculation: BullBOS(T) = LastClose(T) > SwingHigh(T)
Calculation: BearBOS(T) = LastClose(T) < SwingLow(T)
Calculation: BullImpulse(T) = close > open AND abs(close - open) / (high - low) >= body ratio minimum AND high - low >= impulse ATR multiple * ATRv(T) AND close > high[1], on T bars, last completed bar
Calculation: BearImpulse(T) = close < open AND abs(close - open) / (high - low) >= body ratio minimum AND high - low >= impulse ATR multiple * ATRv(T) AND close < low[1], on T bars, last completed bar
Calculation: BullFVG(T) = low > high[2] AND low - high[2] > FVG ATR multiple * ATRv(T), on T bars, last completed bar
Calculation: BearFVG(T) = high < low[2] AND low[2] - high > FVG ATR multiple * ATRv(T), on T bars, last completed bar
Calculation: BullIntent(T) = BullImpulse(T) OR BullBOS(T) OR BullFVG(T)
Calculation: BearIntent(T) = BearImpulse(T) OR BearBOS(T) OR BearFVG(T)
Calculation: BullImbalance(T) = BullImpulse(T) OR BullFVG(T)
Calculation: BearImbalance(T) = BearImpulse(T) OR BearFVG(T)
Calculation: Recent(X) = X is true on the last completed T3 bar or on any of the previous memory length T3 bars
Calculation: PrevHigh(T) = high of the last completed T bar
Calculation: PrevLow(T) = low of the last completed T bar
Calculation: CurDayOpen(T) = open of the still-forming T bar, aggregated from T3 bars through the last completed T3 bar
Calculation: CurDayHigh(T) = high of the still-forming T bar, aggregated from T3 bars through the last completed T3 bar
Calculation: CurDayLow(T) = low of the still-forming T bar, aggregated from T3 bars through the last completed T3 bar
Calculation: HighSweep(T3) = (high > SwingHigh(T3) AND close < SwingHigh(T3)) OR (high > PrevHigh(T5) AND close < PrevHigh(T5)) OR (high > PrevHigh(T6) AND close < PrevHigh(T6)), on T3 bars, last completed bar
Calculation: LowSweep(T3) = (low < SwingLow(T3) AND close > SwingLow(T3)) OR (low < PrevLow(T5) AND close > PrevLow(T5)) OR (low < PrevLow(T6) AND close > PrevLow(T6)), on T3 bars, last completed bar
Calculation: ExploreUp(T3) = (BullBOS(T3) OR BullImpulse(T3)) AND Recent(BullImbalance(T3)) AND NOT Recent(HighSweep(T3))
Calculation: ExploreDown(T3) = (BearBOS(T3) OR BearImpulse(T3)) AND Recent(BearImbalance(T3)) AND NOT Recent(LowSweep(T3))
Calculation: BullFollowThrough(T3) = Recent(LowSweep(T3)) AND Recent(BullIntent(T3)) AND barssince(BullIntent(T3)) <= barssince(LowSweep(T3))
Calculation: BearFollowThrough(T3) = Recent(HighSweep(T3)) AND Recent(BearIntent(T3)) AND barssince(BearIntent(T3)) <= barssince(HighSweep(T3))
Calculation: TargetAbove(T3) = LastClose(T3) < SwingHigh(T3) OR LastClose(T3) < PrevHigh(T5) OR LastClose(T3) < PrevHigh(T6)
Calculation: TargetBelow(T3) = LastClose(T3) > SwingLow(T3) OR LastClose(T3) > PrevLow(T5) OR LastClose(T3) > PrevLow(T6)
Calculation: DayBiasUp(T3) = CurDayOpen(T5) > (PrevHigh(T5) + PrevLow(T5)) / 2 AND CurDayHigh(T5) <= PrevHigh(T5)
Calculation: DayBiasDown(T3) = CurDayOpen(T5) < (PrevHigh(T5) + PrevLow(T5)) / 2 AND CurDayLow(T5) >= PrevLow(T5)
Calculation: DayBreakHigh(T3) = CurDayHigh(T5) > PrevHigh(T5)
Calculation: DayBreakLow(T3) = CurDayLow(T5) < PrevLow(T5)
Calculation: ExternalBullCount = number of external series S in {dollar index, 10-year yield, 2-year yield} with close(S) > EMA(close(S), external EMA lookback, T4, last completed bar) AND ROC(close(S), external ROC lookback, T4, last completed bar) > 0
Calculation: ExternalBearCount = number of external series S in {dollar index, 10-year yield, 2-year yield} with close(S) < EMA(close(S), external EMA lookback, T4, last completed bar) AND ROC(close(S), external ROC lookback, T4, last completed bar) < 0
Calculation: BullScore = min(score cap, max(0, wM1*[LastClose(T1) > FastEMA(T1)] + wM2*[FastEMA(T1) > SlowEMA(T1)] + wM3*[Slope(T1) > macro slope threshold] + wM4*[0 < Slope(T1) <= macro slope threshold] + wM5*[BullBOS(T1)] + wM6*[BullFVG(T1)] + wM7*[LastClose(T1) > SwingHigh(T1)] + wH1*[LastClose(T2) > FastEMA(T2)] + wH2*[FastEMA(T2) > SlowEMA(T2)] + wH3*[Slope(T2) > HTF slope threshold] + wH4*[0 < Slope(T2) <= HTF slope threshold] + wH5*[BullBOS(T2)] + wH6*[BullImpulse(T2)] + wH7*[BullFVG(T2)] + wD1*[LastClose(T3) > FastEMA(T3)] + wD2*[FastEMA(T3) > SlowEMA(T3)] + wD3*[BullBOS(T3)] + wD4*[BullImpulse(T3)] + wD5*[BullFVG(T3)] + wD6*[ExploreUp(T3)] + wE1*[Recent(LowSweep(T3))] + wE2*[BullFollowThrough(T3)] + wE3*[TargetAbove(T3)] + wE4*[DayBiasUp(T3)] + wE5*[DayBreakLow(T3)] - wPen*[Recent(BearImbalance(T3))] + wExt*ExternalBearCount))
Calculation: BearScore = min(score cap, max(0, wM1*[LastClose(T1) < FastEMA(T1)] + wM2*[FastEMA(T1) < SlowEMA(T1)] + wM3*[Slope(T1) < -macro slope threshold] + wM4*[-macro slope threshold <= Slope(T1) < 0] + wM5*[BearBOS(T1)] + wM6*[BearFVG(T1)] + wM7*[LastClose(T1) < SwingLow(T1)] + wH1*[LastClose(T2) < FastEMA(T2)] + wH2*[FastEMA(T2) < SlowEMA(T2)] + wH3*[Slope(T2) < -HTF slope threshold] + wH4*[-HTF slope threshold <= Slope(T2) < 0] + wH5*[BearBOS(T2)] + wH6*[BearImpulse(T2)] + wH7*[BearFVG(T2)] + wD1*[LastClose(T3) < FastEMA(T3)] + wD2*[FastEMA(T3) < SlowEMA(T3)] + wD3*[BearBOS(T3)] + wD4*[BearImpulse(T3)] + wD5*[BearFVG(T3)] + wD6*[ExploreDown(T3)] + wE1*[Recent(HighSweep(T3))] + wE2*[BearFollowThrough(T3)] + wE3*[TargetBelow(T3)] + wE4*[DayBiasDown(T3)] + wE5*[DayBreakHigh(T3)] - wPen*[Recent(BullImbalance(T3))] + wExt*ExternalBullCount))
Calculation: BullShare = round(BullScore / max(BullScore + BearScore, 1) * 100)
Calculation: BearShare = round(BearScore / max(BullScore + BearScore, 1) * 100)
Long: LastClose(T1) > FastEMA(T1) AND LastClose(T2) > FastEMA(T2) AND (ExploreUp(T3) OR LastClose(T3) > FastEMA(T3))
Long: LastClose(T1) > FastEMA(T1) AND LastClose(T2) < FastEMA(T2) AND (ExploreDown(T3) OR LastClose(T3) < FastEMA(T3))
Short: LastClose(T1) < FastEMA(T1) AND LastClose(T2) < FastEMA(T2) AND (ExploreDown(T3) OR LastClose(T3) < FastEMA(T3))
Short: LastClose(T1) < FastEMA(T1) AND LastClose(T2) > FastEMA(T2) AND (ExploreUp(T3) OR LastClose(T3) > FastEMA(T3))
Long: BullShare - BearShare >= confidence threshold
Short: BearShare - BullShare >= confidence threshold