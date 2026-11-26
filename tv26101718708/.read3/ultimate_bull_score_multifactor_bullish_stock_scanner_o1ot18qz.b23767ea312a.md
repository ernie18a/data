Calculation: Clip(x, lo, hi) = MAX(lo, MIN(hi, x))
Calculation: Scale(x, lo, hi) = Clip((x - lo) / (hi - lo), 0, 1)
Calculation: Flag(c) = 1 if c is true, else 0
Calculation: Range(n) = HIGHEST(high, n) - LOWEST(low, n)
Calculation: Rep(series, k) = value of the k-th most recent quarterly report of series (k = 0 is latest), where series is revenue (total revenue), eps (diluted EPS), fcf (free cash flow) or income (net income); undefined when the latest report of series is older than report freshness bars
Calculation: AvgVolume = SMA(volume, volume average length)
Calculation: VolumeOK = AvgVolume > 0
Calculation: Ready = chart timeframe is T1 AND bars so far >= MAX(warm-up bars, long SMA length + warm-up margin) AND RS20 and RS60 are defined
Calculation: FastEMA = EMA(close, fast EMA length)
Calculation: MidEMA = EMA(close, mid EMA length)
Calculation: MedSMA = SMA(close, medium SMA length)
Calculation: LongSMA = SMA(close, long SMA length)
Calculation: FastRising = FastEMA > FastEMA[fast EMA rise lag]
Calculation: MidRising = MidEMA > MidEMA[mid EMA rise lag]
Calculation: MedRising = MedSMA > MedSMA[medium SMA rise lag]
Calculation: ATR = ATR(ATR length)
Calculation: Mom20 = ROC(close, short ROC length)
Calculation: Mom60 = ROC(close, long ROC length)
Calculation: RS20 = Mom20 - ROC(benchmark close, benchmark short ROC length)
Calculation: RS60 = Mom60 - ROC(benchmark close, benchmark long ROC length)
Calculation: RatioEMA = EMA(close / benchmark close, ratio EMA length)
Calculation: Slope = ROC(MidEMA, slope length)
Calculation: Extension = 100 * (close / MidEMA - 1)
Calculation: OBV = On-balance volume of close and volume
Calculation: OBVEMA = EMA(OBV, OBV EMA length)
Calculation: Resistance = HIGHEST(high[1], pattern lookback)
Calculation: ResistanceBreakout = close > Resistance AND close[1] <= Resistance
Calculation: Accumulation = SMA(Flag(close > close[1] AND volume > AvgVolume), accumulation window)
Calculation: ADLine = Accumulation/distribution line of high, low, close and volume
Calculation: ADPos = 100 * (ADLine - LOWEST(ADLine, AD range length)) / (HIGHEST(ADLine, AD range length) - LOWEST(ADLine, AD range length)) if the denominator is greater than 0, else 50
Calculation: VolumeScore = strong volume points * Flag(volume / AvgVolume >= strong volume ratio) + OBV points * Flag(OBV > OBV[OBV rise lag]) + Flag(ADLine > EMA(ADLine, AD EMA length)) + Flag(ADLine > ADLine[AD short lag]) + Flag(ADPos >= AD position threshold) + Flag(ADLine > ADLine[AD long lag] AND close <= close[AD long lag])
Calculation: AccumPoints = IF VolumeOK, accumulation points * VolumeScore / (strong volume points + OBV points + AD flag count), else 0
Calculation: OscPasses = Flag(RSI >= RSI lower band AND RSI <= RSI upper band) + Flag(MACD line > MACD signal line) + Flag(MACD line > 0) + Flag(MACD histogram > MACD histogram[1]) + Flag(Stoch %K > SMA(Stoch %K, stoch smoothing length) AND Stoch %K > stoch level AND Stoch %K < stoch upper level) + Flag(StochRSI > SMA(StochRSI, StochRSI smoothing length) AND StochRSI > StochRSI level) + Flag(CCI > 0 AND CCI < CCI ceiling) + Flag(MFI > MFI floor AND MFI < MFI ceiling) + Flag(ROC(close, ROC length) > 0) + Flag(Williams %R > Williams floor AND Williams %R < Williams ceiling) + Flag(PPO > EMA(PPO, PPO signal length) AND PPO > 0) + Flag(TSI > EMA(TSI, TSI signal length) AND TSI > 0) + Flag(Ultimate Oscillator > UO floor AND Ultimate Oscillator < UO ceiling) + Flag(CMF > 0) + Flag(Aroon up > Aroon down AND Aroon up >= Aroon threshold), where MACD = MACD(close, MACD fast length, MACD slow length, MACD signal length), Stoch %K and StochRSI use stoch length (StochRSI on RSI), CCI and MFI use typical price, CCI length and MFI length, Williams %R uses Williams length, PPO = PPO(close, PPO fast length, PPO slow length), TSI = TSI(close, TSI long length, TSI short length), Ultimate Oscillator uses UO short, mid and long periods, CMF uses CMF length, Aroon up and down use Aroon length
Calculation: OscScore = ROUND(oscillator points * OscPasses / number of oscillator checks)
Calculation: TrendPoints = trend points * (sum over k of w_trend[k] * Flag(c_k)) / (sum over k of w_trend[k]), where c_1 = close > FastEMA, c_2 = close > MidEMA, c_3 = close > MedSMA, c_4 = close > LongSMA, c_5 = FastEMA > MidEMA AND MidEMA > MedSMA, c_6 = MedSMA > LongSMA, c_7 = FastRising, c_8 = MidRising, c_9 = MedRising
Calculation: RSPoints = RS20 points * Scale(RS20, RS20 floor, RS20 ceiling) + RS60 points * Scale(RS60, RS60 floor, RS60 ceiling) + RS ratio points * Flag(close / benchmark close > RatioEMA AND RatioEMA > RatioEMA[ratio slope lag])
Calculation: MomentumPoints = momentum oscillator points * OscScore / oscillator points + Mom20 points * Scale(Mom20, Mom20 floor, Mom20 ceiling) + Mom60 points * Scale(Mom60, Mom60 floor, Mom60 ceiling)
Calculation: BreakoutPoints = breakout pattern points * PatternScore / pattern score cap + breakout structure points * StructureScore / (sum over k of w_struct[k])
Calculation: StructureScore = sum over k of w_struct[k] * Flag(c_k), where c_1 = 0 <= 100 * (Resistance - close) / Resistance <= near resistance %, c_2 = ResistanceBreakout, c_3 = high > high[higher high lag], c_4 = low > low[higher low lag], c_5 = close > LOWEST(low[1], pattern lookback), c_6 = 100 * (HIGHEST(high, MIN(52-week lookback, bars so far)) - close) / HIGHEST(high, MIN(52-week lookback, bars so far)) <= near 52-week high %
Calculation: PatternScore = MIN(pattern score cap, pattern points per pass * PatternPasses)
Calculation: PatternPasses = Flag(BullFlag) + Flag(AscTriangle) + Flag(FallingWedge) + Flag(DoubleBottom) + Flag(CupHandle) + Flag(VolatilityCoil) + Flag(RetestHold) + Flag(FlatBase) + Flag(RoundedBottom) + Flag(VCP)
Calculation: BullFlag = PoleGain >= minimum pole gain % AND 0 <= Retrace <= maximum flag retracement % AND close > PoleLow, where PoleLow = LOWEST(low[pole low lag], pole span), PoleGain = 100 * (high[pole high lag] / PoleLow - 1), Retrace = 100 * (high[pole high lag] - LOWEST(low, flag span)) / (high[pole high lag] - PoleLow)
Calculation: AscTriangle = sum over i = 0 to triangle span - 1 of Flag(100 * ABS(high[i] - TriRes) / TriRes <= touch tolerance %) >= minimum touches AND LOWEST(low, recent span) > LOWEST(low[early lag], early span) AND close <= TriRes * triangle close band, where TriRes = HIGHEST(high, triangle span)
Calculation: FallingWedge = HighDrop > 0 AND LowDrop > 0 AND HighDrop > LowDrop, where HighDrop = (HIGHEST(high[wedge lag], wedge span) - HIGHEST(high, wedge span)) / HIGHEST(high[wedge lag], wedge span) and LowDrop = (LOWEST(low[wedge lag], wedge span) - LOWEST(low, wedge span)) / LOWEST(low[wedge lag], wedge span)
Calculation: DoubleBottom = 100 * ABS(Bottom2 - Bottom1) / Bottom1 <= double bottom tolerance % AND HIGHEST(high[double bottom middle lag], double bottom middle span) > MAX(Bottom1, Bottom2) * double bottom factor AND close > Bottom2, where Bottom1 = LOWEST(low[bottom lag], bottom span) and Bottom2 = LOWEST(low, bottom span)
Calculation: CupHandle = cup min depth % <= CupDepth <= cup max depth % AND RimDiff <= rim tolerance % AND HandleDepth <= handle max depth %, where CupRim = MAX(high[cup left lag], HIGHEST(high, rim span)), CupDepth = 100 * (CupRim - LOWEST(low[cup bottom lag], cup bottom span)) / CupRim, RimDiff = 100 * ABS(HIGHEST(high, rim span) - high[cup left lag]) / high[cup left lag], HandleDepth = 100 * (CupRim - LOWEST(low, handle span)) / CupRim
Calculation: VolatilityCoil = ATR / close < SMA(ATR / close, volatility average length) AND Range(coil span)[coil span] > 0 AND Range(coil span) < Range(coil span)[coil span]
Calculation: RetestHold = close[1] > PriorBreak AND low <= PriorBreak * retest tolerance factor AND close >= PriorBreak, where PriorBreak = HIGHEST(high[retest lag], retest span)
Calculation: FlatBase = 100 * (HIGHEST(high, base span) - LOWEST(low, base span)) / LOWEST(low, base span) <= flat base range % AND close >= HIGHEST(high, base span) * flat base close factor
Calculation: RoundedBottom = close[rounded left lag] > MidPx * rounded factor AND close > MidPx * rounded factor AND 100 * ABS(close - close[rounded left lag]) / close[rounded left lag] <= rounded tolerance %, where MidPx = LOWEST(close[rounded middle lag], rounded middle span)
Calculation: VCP = Range(VCP long span) > 0 AND Range(VCP mid span) < Range(VCP long span) * VCP contraction factor AND Range(VCP short span) < Range(VCP mid span) * VCP contraction factor
Calculation: RevGrowth = 100 * (Rep(revenue, 0) / Rep(revenue, 4) - 1), defined when Rep(revenue, 4) > 0
Calculation: RevGrowthPrev = 100 * (Rep(revenue, 1) / Rep(revenue, 5) - 1), defined when Rep(revenue, 5) > 0
Calculation: RevAccel = RevGrowth - RevGrowthPrev
Calculation: Margin = 100 * Rep(income, 0) / Rep(revenue, 0), defined when income and revenue have the same latest report bar and Rep(revenue, 0) > 0
Calculation: MarginYA = 100 * Rep(income, 4) / Rep(revenue, 4), defined when income and revenue have the same latest report bar and Rep(revenue, 4) > 0
Calculation: FCFMargin = 100 * Rep(fcf, 0) / Rep(revenue, 0), defined when fcf and revenue have the same latest report bar and Rep(revenue, 0) > 0
Calculation: FCFMarginYA = 100 * Rep(fcf, 4) / Rep(revenue, 4), defined when fcf and revenue have the same latest report bar and Rep(revenue, 4) > 0
Calculation: EpsImp = Scale(100 * (Rep(eps, 0) / Rep(eps, 4) - 1), EPS growth floor, EPS growth ceiling) if Rep(eps, 4) > 0; else 1 if Rep(eps, 0) > 0; else partial credit if Rep(eps, 0) > Rep(eps, 4); else 0; undefined unless Rep(eps, 0) and Rep(eps, 4) are defined
Calculation: FCFImp = Scale(100 * (Rep(fcf, 0) / Rep(fcf, 4) - 1), FCF growth floor, FCF growth ceiling) if Rep(fcf, 4) > 0; else 1 if Rep(fcf, 0) > 0; else partial credit if Rep(fcf, 0) > Rep(fcf, 4); else 0; undefined unless Rep(fcf, 0) and Rep(fcf, 4) are defined
Calculation: PE = close / (Rep(eps, 0) + Rep(eps, 1) + Rep(eps, 2) + Rep(eps, 3)), defined when that sum > 0
Calculation: ValFactor = (1 - Scale(PE / MAX(RevGrowth, growth floor), PE ratio floor, PE ratio ceiling)) if RevGrowth > 0; else partial credit if PE <= valuation PE cutoff; else 0; undefined unless PE and RevGrowth are defined
Calculation: BusFactor = [Scale(RevGrowth, revenue growth floor, revenue growth ceiling), Scale(RevAccel, revenue acceleration floor, revenue acceleration ceiling), Flag(Rep(eps, 0) > 0), EpsImp, Scale(Margin - MarginYA, margin change floor, margin change ceiling), Scale(FCFMargin, FCF margin floor, FCF margin ceiling), FCFImp, Scale(FCFMargin - FCFMarginYA, FCF margin change floor, FCF margin change ceiling), ValFactor], each entry undefined when its inputs are undefined
Calculation: BusinessPoints = sum over j = 1 to 9 of w_bus[j] * (BusFactor[j] if defined, else missing-data credit) + (w_bus[10] + w_bus[11]) * missing-data credit
Calculation: Coverage = 100 * (sum over j = 1 to 9 of w_bus[j] * Flag(BusFactor[j] is defined)) / (sum over j = 1 to 11 of w_bus[j])
Calculation: Penalty = extension weight * Scale(Extension, extension start, extension start + extension penalty span) + parabolic weight * MAX(Scale(ROC(close, parabolic momentum length), parabolic short floor, parabolic short ceiling), Scale(Mom20, parabolic mid floor, parabolic mid ceiling)) + deterioration weight * Flag(close > close[deterioration lag] AND RSI < RSI[deterioration lag]) + deterioration weight * Flag(VolumeOK AND close > close[deterioration lag] AND OBV < OBV[deterioration lag]) + revenue weight * Scale(-RevAccel, revenue penalty floor, revenue penalty ceiling) if RevAccel is defined, else 0 + fcf weight * Scale(100 * (Rep(fcf, 4) - Rep(fcf, 0)) / MAX(ABS(Rep(fcf, 4)), 1), 0, fcf penalty ceiling) if Rep(fcf, 0) < 0 AND Rep(fcf, 0) < Rep(fcf, 4) with both defined, else 0 + valuation weight * Scale(PE, valuation PE floor, valuation PE ceiling) * Scale(valuation growth threshold - RevGrowth, 0, valuation growth span) if PE and RevGrowth are defined AND RevGrowth < valuation growth threshold, else 0
Calculation: RawScore = TrendPoints + RSPoints + MomentumPoints + AccumPoints + BreakoutPoints + BusinessPoints
Calculation: BullScore = Clip(RawScore - Penalty, 0, 100)
Calculation: EntryScore = sum over k of w_entry[k] * Flag(c_k), where c_1 = FastEMA > MidEMA AND BARSSINCE(FastEMA crosses above MidEMA) <= cross age limit, c_2 = Slope > 0 AND Slope > Slope[slope lag], c_3 = close > MedSMA AND BARSSINCE(close crosses above MedSMA) <= reclaim age limit, c_4 = RS20 > 0 AND BARSSINCE(RS20 crosses above 0) <= RS age limit, c_5 = VolumeOK AND OBV > OBVEMA AND close <= close[entry close lag], c_6 = VolumeOK AND Accumulation > Accumulation[accumulation lag], c_7 = Mom20 > 0 AND Mom20 > Mom20[momentum lag], c_8 = Extension >= 0 AND Extension <= maximum extension %
Calculation: PullbackQualified = Ready AND BullScore >= pullback qualified score
Calculation: PullbackTrend = PullbackQualified AND BullScore >= pullback trend score AND FastEMA > MidEMA AND FastRising AND MidRising AND close > MedSMA
Calculation: NormalSupport = MidEMA + ATR * pullback ATR allowance
Calculation: FastSupport = FastEMA + ATR * fast support ATR allowance
Calculation: MaxPrice = MidEMA * (1 + maximum extension % / 100)
Calculation: LastBreakout = VALUEWHEN(ResistanceBreakout, Resistance, 0)
Calculation: RecentBreakout = BARSSINCE(ResistanceBreakout) <= pattern lookback
Calculation: FastValid = PullbackTrend AND FastSupport <= close AND FastSupport <= MaxPrice AND 100 * (close - FastSupport) / close <= pullback max distance %
Calculation: ResValid = PullbackTrend AND Resistance > 0 AND Resistance <= close AND Resistance >= MidEMA AND Resistance <= MaxPrice AND 100 * (close - Resistance) / close <= pullback max distance %
Calculation: BrkValid = PullbackTrend AND RecentBreakout AND LastBreakout > 0 AND LastBreakout <= close AND LastBreakout >= MidEMA AND LastBreakout <= MaxPrice AND 100 * (close - LastBreakout) / close <= pullback max distance %
Calculation: DynamicSupport = MAX(NormalSupport, FastSupport if FastValid, Resistance if ResValid, LastBreakout if BrkValid)
Calculation: PullbackPrice = MIN(DynamicSupport if PullbackTrend, else NormalSupport, MaxPrice), defined only when PullbackQualified
Calculation: NearPullbackArea = PullbackPrice is defined AND close >= MidEMA AND close <= PullbackPrice + ATR * near-entry tolerance
Long: Ready AND BullScore >= strong bull score AND Coverage >= minimum coverage AND Penalty <= maximum risk AND close > MidEMA AND VolumeOK
Long: Ready AND EntryScore >= entry score threshold AND Coverage >= minimum coverage AND Penalty <= maximum risk AND Extension >= 0 AND Extension <= maximum extension % AND FastEMA > MidEMA AND VolumeOK
Long: NearPullbackArea AND Coverage >= minimum coverage AND Penalty <= maximum risk AND VolumeOK