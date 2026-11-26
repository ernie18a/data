Calculation: Points(c, w) = w if c is true, else 0
Calculation: PctGap(a, b) = abs(a - b) / abs(a) * 100
Calculation: VolumeSpike = volume > SMA(volume, volume average length) * volume spike multiple
Calculation: FullUptrend = close > EMA(close, short-term EMA length) AND EMA(close, short-term EMA length) > EMA(close, medium-term EMA length) AND EMA(close, medium-term EMA length) > EMA(close, long-term EMA length)
Calculation: UptrendAligned = close > EMA(close, medium-term EMA length) AND EMA(close, medium-term EMA length) > EMA(close, long-term EMA length)
Calculation: MomentumOk = RSI(close, RSI length) >= RSI minimum AND ROC(close, ROC length) > 0
Calculation: StrongBullCandle = close > open AND (close - low) / (high - low) > strong close position AND abs(close - open) / (high - low) > strong body fraction
Calculation: CandleOk = (close > open AND close[1] < open[1] AND open <= close[1] AND close >= open[1]) OR (close > open AND min(open, close) - low > hammer wick multiple * abs(close - open) AND high - max(open, close) <= abs(close - open) AND (close - low) / (high - low) > hammer close position) OR StrongBullCandle
Calculation: HP(k) = high value of the k-th most recent stored high pivot, where k = 0 is the most recent, high pivots are the non-na values of PivotHigh(high, pivot left bars, pivot right bars), and at most max stored pivots are kept
Calculation: HPB(k) = bar index of the pivot that gives HP(k)
Calculation: LP(k) = low value of the k-th most recent stored low pivot, where k = 0 is the most recent, low pivots are the non-na values of PivotLow(low, pivot left bars, pivot right bars), and at most max stored pivots are kept
Calculation: LPB(k) = bar index of the pivot that gives LP(k)
Calculation: MaxHP(a, b) = highest value among stored high pivots whose bar index is between min(a, b) and max(a, b) inclusive
Calculation: MaxHPB(a, b) = bar index of the pivot that gives MaxHP(a, b)
Calculation: MinLP(a, b) = lowest value among stored low pivots whose bar index is between min(a, b) and max(a, b) inclusive
Calculation: MinLPB(a, b) = bar index of the pivot that gives MinLP(a, b)
Calculation: IHSValid = PctGap(LP(2), LP(0)) <= shoulder tolerance % AND LP(1) < LP(2) AND LP(1) < LP(0) AND abs((LPB(1) - LPB(2)) - (LPB(0) - LPB(1))) <= time symmetry tolerance bars AND close > MaxHP(LPB(2), LPB(1)) + (MaxHP(LPB(1), LPB(0)) - MaxHP(LPB(2), LPB(1))) * (bar index - MaxHPB(LPB(2), LPB(1))) / (MaxHPB(LPB(1), LPB(0)) - MaxHPB(LPB(2), LPB(1))) AND close > EMA(close, short-term EMA length) AND VolumeSpike
Calculation: CupDepth = (min(HP(1), HP(0)) - MinLP(HPB(1), HPB(0))) / min(HP(1), HP(0)) * 100
Calculation: CupHandleValid = PctGap(HP(1), HP(0)) <= cup lip tolerance % AND CupDepth >= cup min depth % AND CupDepth <= cup max depth % AND HPB(1) < MinLPB(HPB(1), HPB(0)) AND MinLPB(HPB(1), HPB(0)) < HPB(0) AND (HP(0) - Lowest(low, bar index - HPB(0) + 1)) / (HP(0) - MinLP(HPB(1), HPB(0))) * 100 <= handle max retrace % AND close > max(HP(1), HP(0)) AND close > EMA(close, short-term EMA length) AND VolumeSpike
Calculation: DBValid = PctGap(LP(1), LP(0)) <= double bottom tolerance % AND close > MaxHP(LPB(1), LPB(0)) AND close > EMA(close, short-term EMA length) AND VolumeSpike
Calculation: FlagPullback = (Highest(high, flag lookback) - close) / (Highest(high, flag lookback) - Lowest(low, flag lookback)) * 100
Calculation: FlagValid = UptrendAligned AND FlagPullback > flag min pullback % AND FlagPullback <= flag max pullback % AND close > high[1] AND VolumeSpike
Calculation: TriValid = PctGap(HP(1), HP(0)) <= triangle tolerance % AND LP(0) > LP(1) AND close > max(HP(0), HP(1)) AND close > EMA(close, short-term EMA length) AND VolumeSpike
Calculation: BreakValid = close > Highest(high[1], breakout lookback) * breakout buffer factor AND close > EMA(close, short-term EMA length) AND VolumeSpike
Calculation: PullValid = FullUptrend AND abs(close - EMA(close, short-term EMA length)) <= ATR(ATR length) AND close > EMA(close, short-term EMA length) AND StrongBullCandle
Calculation: CompValid = UptrendAligned[1] AND high[1] < high[2] AND low[1] > low[2] AND (high[1] - low[1]) < Lowest(high - low, NR lookback)[2] AND volume[1] < SMA(volume, volume average length)[1] AND close > high[1] AND VolumeSpike
Calculation: PatternFound = IHSValid OR CupHandleValid OR DBValid OR FlagValid OR TriValid OR CompValid OR BreakValid OR PullValid
Calculation: StopDistancePct = (close - (IF IHSValid THEN LP(0) ELSE IF CupHandleValid THEN EMA(close, short-term EMA length) ELSE IF DBValid THEN LP(0) ELSE IF FlagValid THEN EMA(close, medium-term EMA length) ELSE IF TriValid THEN LP(0) ELSE IF CompValid THEN low[1] ELSE IF BreakValid THEN EMA(close, short-term EMA length) ELSE IF PullValid THEN EMA(close, medium-term EMA length) ELSE na)) / close * 100
Calculation: TotalScore = (IF IHSValid THEN Points(UptrendAligned, trend-healthy weight) + Points(MomentumOk, momentum weight) + Points(VolumeSpike, volume weight) + IHS base score ELSE IF CupHandleValid THEN Points(UptrendAligned, trend-healthy weight) + Points(MomentumOk, momentum weight) + Points(VolumeSpike, volume weight) + cup base score ELSE IF DBValid THEN Points(UptrendAligned, trend-healthy weight) + Points(MomentumOk, momentum weight) + Points(VolumeSpike, volume weight) + double bottom base score ELSE IF FlagValid THEN Points(FullUptrend, trend-strong weight) + Points(MomentumOk, momentum weight) + Points(VolumeSpike, volume weight) + flag base score ELSE IF TriValid THEN Points(UptrendAligned, trend-healthy weight) + Points(MomentumOk, momentum weight) + Points(VolumeSpike, volume weight) + triangle base score ELSE IF CompValid THEN Points(UptrendAligned, trend-healthy weight) + Points(VolumeSpike, volume weight) + compression base score ELSE IF BreakValid THEN Points(FullUptrend, trend-strong weight) + Points(MomentumOk, momentum weight) + Points(VolumeSpike, volume weight) + breakout base score ELSE IF PullValid THEN Points(FullUptrend, trend-strong weight) + Points(MomentumOk, momentum weight) + Points(CandleOk, pullback candle weight) + pullback base score ELSE 0) + Points(StopDistancePct > 0 AND StopDistancePct <= max risk %, risk bonus) + Points(CandleOk, candle bonus)
Long: PatternFound AND TotalScore >= strong score threshold
Long: PatternFound AND TotalScore >= candidate score threshold
Long: IHSValid
Long: CupHandleValid
Long: DBValid
Long: FlagValid
Long: TriValid