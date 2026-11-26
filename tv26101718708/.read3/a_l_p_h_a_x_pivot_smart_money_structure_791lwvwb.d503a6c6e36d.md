Calculation: BreakHigh = close if close-only break is on, else high
Calculation: BreakLow = close if close-only break is on, else low
Calculation: PivotHighLevel = PivotHigh(high, pivot length, pivot length) if confirmed on this bar, else SwingHighLevel[1]
Calculation: SwingHighLevel = BreakHigh if BreakHigh > PivotHighLevel, else PivotHighLevel
Calculation: PivotLowLevel = PivotLow(low, pivot length, pivot length) if confirmed on this bar, else SwingLowLevel[1]
Calculation: SwingLowLevel = BreakLow if BreakLow < PivotLowLevel, else PivotLowLevel
Calculation: PrevPivotHigh = SwingHighLevel[1] if PivotHigh is confirmed on this bar, else PrevPivotHigh[1]
Calculation: PrevPivotLow = SwingLowLevel[1] if PivotLow is confirmed on this bar, else PrevPivotLow[1]
Calculation: TrendState = -1 if BreakLow < PivotLowLevel, else 1 if BreakHigh > PivotHighLevel, else TrendState[1]
Calculation: LegTop = MAX(PrevPivotHigh, high) if BreakLow < PivotLowLevel, else high if BreakHigh > PivotHighLevel, else MAX(LegTop[1], high)
Calculation: LegBottom = low if BreakLow < PivotLowLevel, else MIN(PrevPivotLow, low) if BreakHigh > PivotHighLevel, else MIN(LegBottom[1], low)
Calculation: Equilibrium = (LegTop + LegBottom) / 2
Calculation: LongRetrace = (LegTop - low) / (LegTop - LegBottom)
Calculation: ShortRetrace = (high - LegBottom) / (LegTop - LegBottom)
Calculation: BullSweep = sweep filter on AND low < Lowest(low[1], sweep lookback) - sweep depth * ATR(ATR length) AND close > Lowest(low[1], sweep lookback) AND close > open
Calculation: BearSweep = sweep filter on AND high > Highest(high[1], sweep lookback) + sweep depth * ATR(ATR length) AND close < Highest(high[1], sweep lookback) AND close < open
Calculation: RecentBullSweep = BullSweep OR BullSweep[1] OR BullSweep[2]
Calculation: RecentBearSweep = BearSweep OR BearSweep[1] OR BearSweep[2]
Calculation: BullConfirmation = close > open AND ((close - low) / (high - low) > rejection ratio OR (close[1] < open[1] AND close >= open[1]))
Calculation: BearConfirmation = close < open AND ((high - close) / (high - low) > rejection ratio OR (close[1] > open[1] AND close <= open[1]))
Calculation: LongScore = (TrendState = 1) + (TrendState = 1 AND shallow OTE ratio <= LongRetrace <= deep OTE ratio) + (PD filter off OR close < Equilibrium) + (HTF filter off OR (EMA(close, shorter lookback, T1, last completed bar) > EMA(close, longer lookback, T1, last completed bar) AND close(T1, last completed bar) > EMA(close, shorter lookback, T1, last completed bar))) + RecentBullSweep + BullConfirmation + ((ADX filter off OR ADX(high, low, close, ADX length) >= ADX minimum) AND (volume filter off OR volume >= SMA(volume, volume average length) * minimum volume ratio))
Calculation: ShortScore = (TrendState = -1) + (TrendState = -1 AND shallow OTE ratio <= ShortRetrace <= deep OTE ratio) + (PD filter off OR close > Equilibrium) + (HTF filter off OR (EMA(close, shorter lookback, T1, last completed bar) < EMA(close, longer lookback, T1, last completed bar) AND close(T1, last completed bar) < EMA(close, shorter lookback, T1, last completed bar))) + RecentBearSweep + BearConfirmation + ((ADX filter off OR ADX(high, low, close, ADX length) >= ADX minimum) AND (volume filter off OR volume >= SMA(volume, volume average length) * minimum volume ratio))
Calculation: BarsSinceEntry = bars since the most recent earlier bar on which a setup A or setup B entry was true on either side
Long: BreakHigh > PivotHighLevel
Long: BullSweep
Long: setup A enabled AND TrendState = 1 AND shallow OTE ratio <= LongRetrace <= deep OTE ratio AND BullConfirmation AND (PD filter off OR close < Equilibrium) AND LongScore >= minimum confluence AND (session filter off OR bar time within active session) AND BarsSinceEntry >= signal cooldown AND (ADX filter off OR ADX(high, low, close, ADX length) >= ADX minimum) AND (volume filter off OR volume >= SMA(volume, volume average length) * minimum volume ratio)
Long: setup B enabled AND TrendState = 1 AND shallow OTE ratio <= LongRetrace <= deep OTE ratio AND BarsSince(BreakHigh > PivotHighLevel AND TrendState[1] <= 0) <= CHoCH window AND RecentBullSweep AND BullConfirmation AND (PD filter off OR close < Equilibrium) AND LongScore >= minimum confluence AND (session filter off OR bar time within active session) AND BarsSinceEntry >= signal cooldown AND (ADX filter off OR ADX(high, low, close, ADX length) >= ADX minimum) AND (volume filter off OR volume >= SMA(volume, volume average length) * minimum volume ratio)
Short: BreakLow < PivotLowLevel
Short: BearSweep
Short: setup A enabled AND TrendState = -1 AND shallow OTE ratio <= ShortRetrace <= deep OTE ratio AND BearConfirmation AND (PD filter off OR close > Equilibrium) AND ShortScore >= minimum confluence AND (session filter off OR bar time within active session) AND BarsSinceEntry >= signal cooldown AND (ADX filter off OR ADX(high, low, close, ADX length) >= ADX minimum) AND (volume filter off OR volume >= SMA(volume, volume average length) * minimum volume ratio)
Short: setup B enabled AND TrendState = -1 AND shallow OTE ratio <= ShortRetrace <= deep OTE ratio AND BarsSince(BreakLow < PivotLowLevel AND TrendState[1] >= 0) <= CHoCH window AND RecentBearSweep AND BearConfirmation AND (PD filter off OR close > Equilibrium) AND ShortScore >= minimum confluence AND (session filter off OR bar time within active session) AND BarsSinceEntry >= signal cooldown AND (ADX filter off OR ADX(high, low, close, ADX length) >= ADX minimum) AND (volume filter off OR volume >= SMA(volume, volume average length) * minimum volume ratio)