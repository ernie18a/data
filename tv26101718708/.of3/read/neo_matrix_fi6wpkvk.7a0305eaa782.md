Calculation: Center(S) = SuperSmoother(hlc3(S), longer core length)
Calculation: StdRatio(S) = StDev(hlc3(S), shorter adapt length) / EMA(StDev(hlc3(S), shorter adapt length), longer core length)
Calculation: AdaptFactor(S) = clamp(1 + adapt gain * (EMA(StdRatio(S), shorter ratio smoothing length) - 1), adapt min, adapt max)
Calculation: StretchBase(S) = SuperSmoother(TR(S), shorter stretch range length) * PI * stretch base multiplier * AdaptFactor(S)
Calculation: StretchUp(S) = high(S) >= Center(S) + StretchBase(S)
Calculation: StretchDown(S) = low(S) <= Center(S) - StretchBase(S)
Calculation: GuardUpper(S) = SuperSmoother(close(S), shorter guard smooth length) + guard multiplier * ATR(S, longer guard length)
Calculation: GuardLower(S) = SuperSmoother(close(S), shorter guard smooth length) - guard multiplier * ATR(S, longer guard length)
Calculation: GuardTrail(S) = max(GuardLower(S), Guard(S)[1]) if GuardDir(S)[1] = 1, else min(GuardUpper(S), Guard(S)[1])
Calculation: GuardDir(S) = -1 if GuardDir(S)[1] = 1 AND close(S) < GuardTrail(S) on each of the last guard confirm closes bars; +1 if GuardDir(S)[1] = -1 AND close(S) > GuardTrail(S) on each of the last guard confirm closes bars; else GuardDir(S)[1]
Calculation: Guard(S) = GuardUpper(S) if GuardDir(S) < GuardDir(S)[1]; GuardLower(S) if GuardDir(S) > GuardDir(S)[1]; else GuardTrail(S)
Calculation: TrendMove(S, L, M) = +1 if hlc3(S) > TrendLine(S, L, M)[1] + TrendHeld(S, L, M)[1]; -1 if hlc3(S) < TrendLine(S, L, M)[1] - TrendHeld(S, L, M)[1]; else 0
Calculation: TrendLine(S, L, M) = TrendLine(S, L, M)[1] + TrendMove(S, L, M) * ATR(S, L) * M
Calculation: TrendHeld(S, L, M) = ATR(S, L) * M if TrendMove(S, L, M) != 0; else TrendHeld(S, L, M)[1]
Calculation: TrendDir(S, L, M) = sign of the latest nonzero TrendMove(S, L, M)
Calculation: CandleSrc(S) = hlc3(S) or Center(S), selected by candle source
Calculation: MacdLine(S) = MACD line of CandleSrc(S), candle fast length, candle slow length, candle signal length
Calculation: MacdHist(S) = MACD histogram of CandleSrc(S), candle fast length, candle slow length, candle signal length
Calculation: Flow(S) = SMA(MFI(hl2(S), flow length) - 50, shorter flow smooth length)
Calculation: PosAvg(S) = mean of PosMem(S), updated each bar: if Flow(S) > 0, Flow(S) is added to PosMem and its oldest entry is dropped when PosMem holds more than flow memory length entries; if Flow(S) < 0 AND PosMem holds more than 1 entry, its oldest entry is dropped
Calculation: NegAvg(S) = mean of NegMem(S), updated each bar: if Flow(S) < 0, Flow(S) is added to NegMem and its oldest entry is dropped when NegMem holds more than flow memory length entries; if Flow(S) > 0 AND NegMem holds more than 1 entry, its oldest entry is dropped
Calculation: CenterSlope(S) = Center(S) - Center(S)[shorter slope lookback]
Calculation: SlopeMove(S) = slope range ratio * (Highest(CenterSlope(S), longer slope range length) - Lowest(CenterSlope(S), longer slope range length))
Calculation: FlowMove(S) = flow range ratio * (Highest(Flow(S), longer flow range length) - Lowest(Flow(S), longer flow range length))
Calculation: HistPower(S) = abs(MacdHist(S)) - abs(MacdHist(S)[shorter hist direction lookback])
Calculation: HistMove(S) = hist range ratio * (Highest(MacdHist(S), longer hist range length) - Lowest(MacdHist(S), longer hist range length))
Calculation: LongScore(S) = SMA(flow weight * I((Flow(S) - Flow(S)[shorter flow direction lookback] > FlowMove(S)) OR (Flow(S) > 0 AND Flow(S) > Flow(S)[1])) + slope weight * I(CenterSlope(S) > SlopeMove(S)) + hist weight * I((MacdHist(S) > 0 AND HistPower(S) > HistMove(S)) OR (MacdHist(S) < 0 AND HistPower(S) < -HistMove(S))), context lookback)[1] + stretch weight * I(StretchDown(S))
Calculation: ShortScore(S) = SMA(flow weight * I((Flow(S) - Flow(S)[shorter flow direction lookback] < -FlowMove(S)) OR (Flow(S) < 0 AND Flow(S) < Flow(S)[1])) + slope weight * I(CenterSlope(S) < -SlopeMove(S)) + hist weight * I((MacdHist(S) < 0 AND HistPower(S) > HistMove(S)) OR (MacdHist(S) > 0 AND HistPower(S) < -HistMove(S))), context lookback)[1] + stretch weight * I(StretchUp(S))
Calculation: LongAllowed(S) = Highest(I(Flow(S) < min(NegAvg(S), -flow strong offset)), context lookback)[1] = 0 AND NOT StretchUp(S)
Calculation: ShortAllowed(S) = Highest(I(Flow(S) > max(PosAvg(S), flow strong offset)), context lookback)[1] = 0 AND NOT StretchDown(S)
Calculation: SetupTouch(S) = (GuardDir(S)[1] = 1 AND low(S) <= Guard(S)[1] + defense shadow multiplier * ATR(S, longer guard length)[1]) OR (GuardDir(S)[1] = -1 AND high(S) >= Guard(S)[1] - defense shadow multiplier * ATR(S, longer guard length)[1]) OR StretchUp(S) OR StretchDown(S)
Long: MacdLine(chart bars) > 0 AND MacdHist(chart bars) > 0
Short: MacdLine(chart bars) < 0 AND MacdHist(chart bars) < 0
Long: GuardDir(chart bars) = 1
Short: GuardDir(chart bars) = -1
Long: GuardDir(chart bars) = 1 AND TrendDir(chart bars, longer chart trend length, chart trend multiplier) = 1
Short: GuardDir(chart bars) = -1 AND TrendDir(chart bars, longer chart trend length, chart trend multiplier) = -1
Long: Flow(chart bars) > 0 AND Flow(chart bars) >= PosAvg(chart bars)
Short: Flow(chart bars) < 0 AND Flow(chart bars) <= NegAvg(chart bars)
Long: SetupTouch(chart bars) AND LongAllowed(chart bars) AND (NOT ShortAllowed(chart bars) OR LongScore(chart bars) > ShortScore(chart bars))
Short: SetupTouch(chart bars) AND ShortAllowed(chart bars) AND (NOT LongAllowed(chart bars) OR ShortScore(chart bars) > LongScore(chart bars))
Long: GuardDir(compare T1 bars)[last completed] = 1 AND TrendDir(compare T1 bars, longer compare trend length, compare trend multiplier)[last completed] = 1
Short: GuardDir(compare T1 bars)[last completed] = -1 AND TrendDir(compare T1 bars, longer compare trend length, compare trend multiplier)[last completed] = -1
Long: Flow(compare T1 bars)[last completed] > 0 AND Flow(compare T1 bars)[last completed] >= PosAvg(compare T1 bars)[last completed]
Short: Flow(compare T1 bars)[last completed] < 0 AND Flow(compare T1 bars)[last completed] <= NegAvg(compare T1 bars)[last completed]
Long: SetupTouch(compare T1 bars)[last completed] AND LongAllowed(compare T1 bars)[last completed] AND (NOT ShortAllowed(compare T1 bars)[last completed] OR LongScore(compare T1 bars)[last completed] > ShortScore(compare T1 bars)[last completed])
Short: SetupTouch(compare T1 bars)[last completed] AND ShortAllowed(compare T1 bars)[last completed] AND (NOT LongAllowed(compare T1 bars)[last completed] OR ShortScore(compare T1 bars)[last completed] > LongScore(compare T1 bars)[last completed])