Calculation: AvgTrueRange = ATR(high, low, close, ATR length)
Calculation: FastStoch = SMA(Stochastic(high, low, close, shorter stochastic length), smoothing length)
Calculation: SlowStoch = SMA(Stochastic(high, low, close, longer stochastic length), smoothing length)
Calculation: TsiValue = TSI(close, shorter TSI length, longer TSI length)
Calculation: TsiSignal = EMA(TsiValue, TSI signal length)
Calculation: RsiValue = RSI(close, RSI length)
Calculation: HmaValue = HMA(close, HMA length)
Calculation: CciValue = CCI((high + low + close) / 3, CCI length)
Calculation: ShortDema = DEMA(close, shorter MA length)
Calculation: ShortEma = EMA(close, shorter MA length)
Calculation: LongDema = DEMA(close, longer MA length)
Calculation: LongEma = EMA(close, longer MA length)
Calculation: LongSma = SMA(close, longer MA length)
Calculation: AboveShortMas = close > ShortDema AND close > ShortEma
Calculation: AboveLongMas = close > LongDema AND close > LongEma AND close > LongSma
Calculation: BelowShortMas = close < ShortDema AND close < ShortEma
Calculation: BelowLongMas = close < LongDema AND close < LongEma AND close < LongSma
Calculation: SetupGate = (timeframe filter off OR chart period in seconds is between minimum and maximum period) AND (date filter off OR bar time is between start and end) AND (confirmed-only off OR bar is closed)
Calculation: BullSetup = SetupGate AND (TSI filter off OR (TsiValue > TsiSignal AND TsiValue > TsiValue[1])) AND (RSI filter off OR (RsiValue > RSI buy level AND RsiValue >= RsiValue[1])) AND (HMA filter off OR (close > HmaValue AND HmaValue > HmaValue[1])) AND (CCI filter off OR (CciValue > CCI lower limit AND CciValue > CciValue[1]))
Calculation: BearSetup = SetupGate AND (TSI filter off OR (TsiValue < TsiSignal AND TsiValue < TsiValue[1])) AND (RSI filter off OR (RsiValue < RSI sell level AND RsiValue <= RsiValue[1])) AND (HMA filter off OR (close < HmaValue AND HmaValue < HmaValue[1])) AND (CCI filter off OR (CciValue < CCI upper limit AND CciValue < CciValue[1]))
Calculation: PivotTop = IF frame engine THEN highest(IF body flag THEN max(open, close) ELSE high, FrameLength) ELSE IF body flag THEN max(open, close) ELSE high of last completed T1 bar
Calculation: PivotBottom = IF frame engine THEN lowest(IF body flag THEN min(open, close) ELSE low, FrameLength) ELSE IF body flag THEN min(open, close) ELSE low of last completed T1 bar
Calculation: FrameLength = max(round(frame size * frame multiplier), minimum frame length)
Calculation: PivotStep = max((PivotTop - PivotBottom) / grid divisions, minimum price increment)
Calculation: Level(k) = PivotBottom + PivotStep * k, for k in -1, 0, 1, 2, 3, 5, 6, 7, 8
Calculation: UpperLevel = PivotTop + PivotStep
Calculation: NearLevel(k) = ABS(close - Level(k)) <= AvgTrueRange * signal zone multiple
Calculation: PivotalBuyZone = NearLevel(0) OR NearLevel(1) OR NearLevel(2) OR NearLevel(3) OR close <= Level(-1)
Calculation: PivotalSellZone = NearLevel(5) OR NearLevel(6) OR NearLevel(7) OR NearLevel(8) OR close >= UpperLevel
Calculation: StrongLow = low of the most recent pivot low (strong left bars, strong right bars) that is at or below the lowest low of the last strong lookback bars ending at that pivot bar
Calculation: StrongHigh = high of the most recent pivot high (strong left bars, strong right bars) that is at or above the highest high of the last strong lookback bars ending at that pivot bar
Calculation: BullSweep = StrongLow[1] exists AND low < StrongLow[1] AND close > StrongLow[1]
Calculation: BearSweep = StrongHigh[1] exists AND high > StrongHigh[1] AND close < StrongHigh[1]
Calculation: LastPivotHigh = price of the most recent confirmed pivot high (strong left bars, strong right bars)
Calculation: LastPivotLow = price of the most recent confirmed pivot low (strong left bars, strong right bars)
Calculation: LastLowIsHigherLow = the most recent pivot low is greater than the pivot low before it
Calculation: LastHighIsLowerHigh = the most recent pivot high is not greater than the pivot high before it
Calculation: BullBos = LastPivotHigh exists AND close crosses above LastPivotHigh
Calculation: BearBos = LastPivotLow exists AND close crosses below LastPivotLow
Calculation: StructureState = Bullish if BullBos OR LastLowIsHigherLow, else Bearish if BearBos OR LastHighIsLowerHigh, else unchanged (initially neutral)
Calculation: HtfLong = last completed T2 bar close > DEMA(close, shorter MA length) AND > EMA(close, shorter MA length) AND > DEMA(close, longer MA length) AND > EMA(close, longer MA length) AND > SMA(close, longer MA length), with these averages computed on T2 bars
Calculation: HtfShort = last completed T2 bar close < DEMA(close, shorter MA length) AND < EMA(close, shorter MA length) AND < DEMA(close, longer MA length) AND < EMA(close, longer MA length) AND < SMA(close, longer MA length), with these averages computed on T2 bars
Calculation: FarFromBlocks(price) = for every block in BlockList of the previous bar, ABS(price - block mid) > AvgTrueRange * block spacing multiple
Calculation: BlockList = blocks capped at max block count with oldest removed first; on each bar a support block is appended when SupportBlockCreated and a resistance block is appended when ResistanceBlockCreated, each with mid = its pivot price and top and bottom = mid plus and minus AvgTrueRange * block thickness at creation; then each support block whose close is below its bottom becomes resistance type, and each resistance block whose close is above its top becomes support type
Calculation: SupportBlockCreated = PivotLow(low, block left bars, block right bars) exists AND (precise filter off OR BullSetup) AND (no support block created yet OR bars since last support block creation >= block cooldown) AND FarFromBlocks(PivotLow(low, block left bars, block right bars))
Calculation: ResistanceBlockCreated = PivotHigh(high, block left bars, block right bars) exists AND (precise filter off OR BearSetup) AND (no resistance block created yet OR bars since last resistance block creation >= block cooldown) AND FarFromBlocks(PivotHigh(high, block left bars, block right bars))
Calculation: SupportBlockNear = some block in BlockList of support type has ABS(close - block mid) <= AvgTrueRange * block confirm multiple OR (high >= block bottom AND low <= block top)
Calculation: SupportBlockReject = some block in BlockList of support type has low <= block top AND close > block bottom AND close > open
Calculation: ResistanceBlockNear = some block in BlockList of resistance type has ABS(close - block mid) <= AvgTrueRange * block confirm multiple OR (high >= block bottom AND low <= block top)
Calculation: ResistanceBlockReject = some block in BlockList of resistance type has high >= block bottom AND close < block top AND close < open
Calculation: LongSignalContext = (StrongLow exists AND ABS(close - StrongLow) <= AvgTrueRange * signal zone multiple) OR BullSweep OR SupportBlockReject OR SupportBlockNear OR PivotalBuyZone
Calculation: ShortSignalContext = (StrongHigh exists AND ABS(close - StrongHigh) <= AvgTrueRange * signal zone multiple) OR BearSweep OR ResistanceBlockReject OR ResistanceBlockNear OR PivotalSellZone
Calculation: LongScore = context weight if ((StrongLow exists AND ABS(close - StrongLow) <= AvgTrueRange * score zone multiple) OR a strong low was confirmed within the last fresh bars count OR BullSweep OR SupportBlockNear OR PivotalBuyZone) + MA weight if ((AboveShortMas AND AboveLongMas) OR close crosses above ShortDema OR close crosses above ShortEma OR ShortDema > ShortDema[1] OR LongDema > LongDema[1] OR ShortEma > ShortEma[1] OR LongEma > LongEma[1] OR LongSma > LongSma[1]) + short MA weight if AboveShortMas + long MA weight if AboveLongMas + stochastic weight if (FastStoch > SlowStoch AND FastStoch > FastStoch[1]) + structure weight if (StructureState = Bullish OR BullBos OR LastLowIsHigherLow) + candle weight if close > open + sweep weight if BullSweep + discount weight if (StrongHigh exists AND StrongLow exists AND StrongHigh > StrongLow AND close < (StrongHigh + StrongLow) / 2) + HTF weight if (HTF filter off OR HtfLong) + block weight if SupportBlockNear + block reject weight if SupportBlockReject + key level weight if NearLevel(2), else pivot level weight if NearLevel(0) OR NearLevel(1) OR NearLevel(3) + extreme weight if close <= Level(-1) + setup weight if BullSetup
Calculation: ShortScore = context weight if ((StrongHigh exists AND ABS(close - StrongHigh) <= AvgTrueRange * score zone multiple) OR a strong high was confirmed within the last fresh bars count OR BearSweep OR ResistanceBlockNear OR PivotalSellZone) + MA weight if ((BelowShortMas AND BelowLongMas) OR close crosses below ShortDema OR close crosses below ShortEma OR ShortDema < ShortDema[1] OR LongDema < LongDema[1] OR ShortEma < ShortEma[1] OR LongEma < LongEma[1] OR LongSma < LongSma[1]) + short MA weight if BelowShortMas + long MA weight if BelowLongMas + stochastic weight if (FastStoch < SlowStoch AND FastStoch < FastStoch[1]) + structure weight if (StructureState = Bearish OR BearBos OR LastHighIsLowerHigh) + candle weight if close < open + sweep weight if BearSweep + premium weight if (StrongHigh exists AND StrongLow exists AND StrongHigh > StrongLow AND close > (StrongHigh + StrongLow) / 2) + HTF weight if (HTF filter off OR HtfShort) + block weight if ResistanceBlockNear + block reject weight if ResistanceBlockReject + key level weight if NearLevel(6), else pivot level weight if NearLevel(5) OR NearLevel(7) OR NearLevel(8) + extreme weight if close >= UpperLevel + setup weight if BearSetup
Calculation: LongRaw = LongScore >= long score threshold AND LongSignalContext AND NOT ShortSignalContext AND (HTF filter off OR HtfLong)
Calculation: ShortRaw = ShortScore >= short score threshold AND ShortSignalContext AND NOT LongSignalContext AND (HTF filter off OR HtfShort)
Long: LongRaw AND (first-only off OR NOT LongRaw[1])
Short: ShortRaw AND (first-only off OR NOT ShortRaw[1])
Long: LongScore >= long score threshold AND LongSignalContext
Short: ShortScore >= short score threshold AND ShortSignalContext
Long: SupportBlockCreated
Short: ResistanceBlockCreated