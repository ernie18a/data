Calculation: ATR = ATR(atrLen)
Calculation: RSI = RSI(close, rsiLen)
Calculation: ADX = ADX(dmiLen)
Calculation: Ef = EMA(close, nFast[prof])
Calculation: Es = EMA(close, nSlow[prof])
Calculation: Eq = VWAP(hlc3) if prof is P1, else Ef
Calculation: SupT = low of last completed bar of T1 if prof is P1, else of T3
Calculation: ResT = high of last completed bar of T1 if prof is P1, else of T3
Calculation: CloseB = close of last completed bar of T2 if prof is P1, else of T4
Calculation: EmaB = EMA(close, nSlow[prof]) on last completed bar of T2 if prof is P1, else T4
Calculation: EmaBprev = EmaB one bias bar earlier
Calculation: BiasDir = 1 if CloseB > EmaB AND EmaB > EmaBprev; -1 if CloseB < EmaB AND EmaB < EmaBprev; else 0
Calculation: Touch(L) = low <= L + ATR * zoneMult AND high >= L - ATR * zoneMult
Calculation: ReactBuy = Touch(SupT) AND close > SupT AND (MIN(open, close) - low) / (high - low) >= wickMin AND close > open
Calculation: ReactSell = Touch(ResT) AND close < ResT AND (high - MAX(open, close)) / (high - low) >= wickMin AND close < open
Calculation: ReactBuyRecent = BarsSince(ReactBuy) <= rxMem
Calculation: ReactSellRecent = BarsSince(ReactSell) <= rxMem
Calculation: EqTouch = low <= Eq + ATR * pbMult AND high >= Eq - ATR * pbMult
Calculation: BullPB = (Touch(SupT) OR EqTouch) AND close > open AND close >= Eq
Calculation: BearPB = (Touch(ResT) OR EqTouch) AND close < open AND close <= Eq
Calculation: BullPBRecent = BarsSince(BullPB) <= rxMem
Calculation: BearPBRecent = BarsSince(BearPB) <= rxMem
Calculation: MicroUp = close > HIGHEST(high[1], nMicro[prof])
Calculation: MicroDn = close < LOWEST(low[1], nMicro[prof])
Calculation: PxVel = EMA(close - close[1], nVel)
Calculation: BullMom = (RSI >= bullT1 ? bullP1 : RSI >= bullT2 ? bullP2 : RSI >= bullT3 ? bullP3 : 0) + (RSI > RSI[1] ? bullRsiRiseP : 0) + (PxVel > 0 ? bullVelP : 0) + (Ef > Es ? bullEmaP : 0) + (ROC(close, nRoc) > 0 ? bullRocP : 0)
Calculation: BearMom = (RSI <= bearT1 ? bearP1 : RSI <= bearT2 ? bearP2 : RSI <= bearT3 ? bearP3 : 0) + (RSI < RSI[1] ? bearRsiFallP : 0) + (PxVel < 0 ? bearVelP : 0) + (Ef < Es ? bearEmaP : 0) + (ROC(close, nRoc) < 0 ? bearRocP : 0)
Calculation: VolAvail = volume > 0 AND SMA(volume, nVolAvg) > 0
Calculation: RelVol = volume / SMA(volume, nVolAvg)
Calculation: VolOK = NOT volFilterOn OR NOT VolAvail OR RelVol >= relVolMin
Calculation: VolStrong = NOT VolAvail OR RelVol >= relVolStrong
Calculation: LongStop = LOWEST(low, nStop[prof]) - ATR * stopPad
Calculation: ShortStop = HIGHEST(high, nStop[prof]) + ATR * stopPad
Calculation: LongRROK = ResT <= close OR (ResT - close) / (close - LongStop) >= rrMin
Calculation: ShortRROK = SupT >= close OR (close - SupT) / (ShortStop - close) >= rrMin
Calculation: RegimeStr = regimeScale * (wAdx * clamp01(ADX / adxDiv) + wEr * KER(close, nRegime[prof]) + wSep * clamp01(ABS(Ef - Es) / ATR / sepDiv) + wSlope * clamp01(ABS(Es - Es[nSlope]) / ATR / slopeDiv)), where clamp01(x) = MIN(1, MAX(0, x))
Calculation: TrendSign = 1 if Ef > Es AND Es >= Es[nSlope]; -1 if Ef < Es AND Es <= Es[nSlope]; else 0
Calculation: BullExp = TrendSign == 1 AND RegimeStr >= expMin
Calculation: BearExp = TrendSign == -1 AND RegimeStr >= expMin
Calculation: CompState = RegimeStr <= compMax OR ADX < compAdxMax
Calculation: BullExpRecent = BarsSince(BullExp) <= revMem
Calculation: BearExpRecent = BarsSince(BearExp) <= revMem
Calculation: M1Active = prof is P1 AND m1On
Calculation: IRSI = RSI(close, rsiLen) on intrabar bars, where intrabar bars are T0 bars if prof is P1, else chart bars
Calculation: IRelVol = volume / SMA(volume, m1VolN) if volume > 0 and SMA(volume, m1VolN) > 0, else 1
Calculation: BullExtI = IRSI[1] <= m1Os AND IRSI[1] < IRSI[2] AND IRSI > IRSI[1]
Calculation: BearExtI = IRSI[1] >= m1Ob AND IRSI[1] > IRSI[2] AND IRSI < IRSI[1]
Calculation: BullMomI = IRSI[1] <= m1BullHi AND IRSI[1] > m1BullLo AND IRSI > IRSI[1]
Calculation: BearMomI = IRSI[1] >= m1BearLo AND IRSI[1] < m1BearHi AND IRSI < IRSI[1]
Calculation: BullScoreI = (BullExtI ? m1ExtP : BullMomI ? m1MomP : (IRSI > m1Mid AND IRSI > IRSI[1]) ? m1RsiP : 0) + (close > open ? m1BodyP : 0) + (close > high[1] ? m1BrkP : 0) + (EMA(close, m1Fast) > EMA(close, m1Slow) ? m1EmaP : 0) + (IRelVol >= m1RelThr ? m1VolP : 0) + (IRSI > IRSI[1] AND IRSI[1] > IRSI[2] ? m1TurnP : 0)
Calculation: BearScoreI = (BearExtI ? m1ExtP : BearMomI ? m1MomP : (IRSI < m1Mid AND IRSI < IRSI[1]) ? m1RsiP : 0) + (close < open ? m1BodyP : 0) + (close < low[1] ? m1BrkP : 0) + (EMA(close, m1Fast) < EMA(close, m1Slow) ? m1EmaP : 0) + (IRelVol >= m1RelThr ? m1VolP : 0) + (IRSI < IRSI[1] AND IRSI[1] < IRSI[2] ? m1TurnP : 0)
Calculation: BullPulseI = BullScoreI >= m1PulseMin AND (BullExtI OR BullMomI OR close > high[1])
Calculation: BearPulseI = BearScoreI >= m1PulseMin AND (BearExtI OR BearMomI OR close < low[1])
Calculation: BullHQI = BullPulseI AND BullScoreI >= m1HQMin
Calculation: BearHQI = BearPulseI AND BearScoreI >= m1HQMin
Calculation: M1Avail = at least one intrabar bar exists within the chart bar
Calculation: M1BullN = number of intrabar bars within the chart bar with BullPulseI
Calculation: M1BearN = number of intrabar bars within the chart bar with BearPulseI
Calculation: M1BullBest = maximum BullScoreI over intrabar bars within the chart bar, 0 if none
Calculation: M1BearBest = maximum BearScoreI over intrabar bars within the chart bar, 0 if none
Calculation: M1BullHQFound = BullHQI is true on at least one intrabar bar within the chart bar
Calculation: M1BearHQFound = BearHQI is true on at least one intrabar bar within the chart bar
Calculation: M1LastDir = 1 if the last intrabar bar within the chart bar with BullPulseI or BearPulseI has BullPulseI; -1 if it has BearPulseI; else 0
Calculation: M1LongEvid = NOT M1Active OR (M1Avail AND M1BullN >= m1MinCount AND (M1LastDir == 1 OR M1BullBest > M1BearBest))
Calculation: M1ShortEvid = NOT M1Active OR (M1Avail AND M1BearN >= m1MinCount AND (M1LastDir == -1 OR M1BearBest > M1BullBest))
Calculation: M1LongGate = prof is not P1 OR NOT m1Req OR M1LongEvid
Calculation: M1ShortGate = prof is not P1 OR NOT m1Req OR M1ShortEvid
Calculation: M1LongAdd = 0 if NOT M1Active; hqBonus if M1BullHQFound; evBonus if M1LongEvid; else 0
Calculation: M1ShortAdd = 0 if NOT M1Active; hqBonus if M1BearHQFound; evBonus if M1ShortEvid; else 0
Calculation: ContLong = contOn AND BullExp AND BiasDir == 1 AND (ReactBuyRecent OR BullPBRecent) AND MicroUp AND BullMom >= contMomMin AND VolOK AND LongRROK AND M1LongGate
Calculation: ContShort = contOn AND BearExp AND BiasDir == -1 AND (ReactSellRecent OR BearPBRecent) AND MicroDn AND BearMom >= contMomMin AND VolOK AND ShortRROK AND M1ShortGate
Calculation: RevLong = revOn AND BearExpRecent AND NOT BearExp AND ReactBuyRecent AND close > Ef AND MicroUp AND BullMom >= revMomMin AND VolOK AND LongRROK AND M1LongGate
Calculation: RevShort = revOn AND BullExpRecent AND NOT BullExp AND ReactSellRecent AND close < Ef AND MicroDn AND BearMom >= revMomMin AND VolOK AND ShortRROK AND M1ShortGate
Calculation: ContLongScore = MIN(scoreCap, (BullExp ? tcExpP : (TrendSign == 1 AND NOT CompState) ? tcTransP : 0) + (BiasDir == 1 ? tcBiasP : 0) + (ReactBuyRecent ? tcReactP : BullPBRecent ? tcPbP : 0) + BullMom * tcMomW + (MicroUp ? tcMicroP : 0) + (VolStrong ? tcVolP : 0) + (LongRROK ? tcRrP : 0) + M1LongAdd)
Calculation: ContShortScore = MIN(scoreCap, (BearExp ? tcExpP : (TrendSign == -1 AND NOT CompState) ? tcTransP : 0) + (BiasDir == -1 ? tcBiasP : 0) + (ReactSellRecent ? tcReactP : BearPBRecent ? tcPbP : 0) + BearMom * tcMomW + (MicroDn ? tcMicroP : 0) + (VolStrong ? tcVolP : 0) + (ShortRROK ? tcRrP : 0) + M1ShortAdd)
Calculation: RevLongScore = MIN(scoreCap, ((BearExpRecent AND NOT BearExp) ? revExpP : 0) + (ReactBuyRecent ? revReactP : 0) + BullMom * revMomW + (MicroUp ? revMicroP : 0) + (close > Ef ? revEmaP : 0) + (VolStrong ? revVolP : 0) + (LongRROK ? revRrP : 0) + M1LongAdd)
Calculation: RevShortScore = MIN(scoreCap, ((BullExpRecent AND NOT BullExp) ? revExpP : 0) + (ReactSellRecent ? revReactP : 0) + BearMom * revMomW + (MicroDn ? revMicroP : 0) + (close < Ef ? revEmaP : 0) + (VolStrong ? revVolP : 0) + (ShortRROK ? revRrP : 0) + M1ShortAdd)
Calculation: LongScore = MAX(ContLong ? ContLongScore : 0, RevLong ? RevLongScore : 0)
Calculation: ShortScore = MAX(ContShort ? ContShortScore : 0, RevShort ? RevShortScore : 0)
Calculation: LongArmed = (ContLong OR RevLong) AND LongScore >= entryMin AND (NOT confirmOn OR bar closed)
Calculation: ShortArmed = (ContShort OR RevShort) AND ShortScore >= entryMin AND (NOT confirmOn OR bar closed)
Calculation: LongFresh = LongArmed AND NOT LongArmed[1]
Calculation: ShortFresh = ShortArmed AND NOT ShortArmed[1]
Calculation: CdClear = no entry yet OR bars since last entry > cdBars
Calculation: LongEntry = no open position AND CdClear AND LongFresh AND (NOT ShortFresh OR LongScore >= ShortScore)
Calculation: ShortEntry = no open position AND CdClear AND ShortFresh AND (NOT LongFresh OR ShortScore > LongScore)
Long: LongEntry
Long: LongEntry AND LongScore >= primeMin
Long: BullExp AND BiasDir == 1 AND BullMom > BearMom AND BullMom >= contMomMin AND BullPBRecent AND VolOK AND M1LongEvid AND M1LastDir == 1 AND LongRROK AND LongEntry AND LongScore >= primeMin
Long: ReactBuy
Long: BullExp AND NOT BullExp[1]
Long: TrendSign == 1 AND NOT CompState
Long: M1Active AND M1BullHQFound
Short: ShortEntry
Short: ShortEntry AND ShortScore >= primeMin
Short: BearExp AND BiasDir == -1 AND BearMom > BullMom AND BearMom >= contMomMin AND BearPBRecent AND VolOK AND M1ShortEvid AND M1LastDir == -1 AND ShortRROK AND ShortEntry AND ShortScore >= primeMin
Short: ReactSell
Short: BearExp AND NOT BearExp[1]
Short: TrendSign == -1 AND NOT CompState
Short: M1Active AND M1BearHQFound
Exit: long, bars since entry >= 1 AND ((count(close < Ef, RSI < exitRsiMid, PxVel < 0) >= exitWeakMin AND BullMom < exitMomMax) OR low <= LongStop(entry bar) OR high >= entry price + (entry price - LongStop(entry bar)) * tp3Mult)
Exit: short, bars since entry >= 1 AND ((count(close > Ef, RSI > exitRsiMid, PxVel > 0) >= exitWeakMin AND BearMom < exitMomMax) OR high >= ShortStop(entry bar) OR low <= entry price - (ShortStop(entry bar) - entry price) * tp3Mult)