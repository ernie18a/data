Calculation: Center = LinReg(close, regression lookback)
Calculation: Slope = Center - Center[1]
Calculation: Trend = 1 if EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) AND Slope >= 0; -1 if EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback) AND Slope <= 0; otherwise 0
Calculation: Deviation = StDev(close - Center, regression lookback)
Calculation: NearLowerZone = close <= Center - Deviation * mid-band multiplier OR low <= Center - Deviation * outer-band multiplier
Calculation: NearUpperZone = close >= Center + Deviation * mid-band multiplier OR high >= Center + Deviation * outer-band multiplier
Calculation: SlopeStrength = ATR(ATR lookback) > 0 ? ABS(Slope) / ATR(ATR lookback) * slope scale : 0
Calculation: LatestPivotHigh = most recent non-NA PivotHigh(high, left pivot bars, right pivot bars)
Calculation: LatestPivotLow = most recent non-NA PivotLow(low, left pivot bars, right pivot bars)
Calculation: VolumeSurge = (SMA(volume, volume average lookback) > 0 ? volume / SMA(volume, volume average lookback) : 1) >= volume surge threshold
Calculation: Span = MAX(high - low, minimum price increment)
Calculation: BodySize = ABS(close - open)
Calculation: BodyRatio = BodySize / Span
Calculation: UpperShadow = high - MAX(open, close)
Calculation: LowerShadow = MIN(open, close) - low
Calculation: ClosePosition = (close - low) / Span
Calculation: BullishCandle = close > open
Calculation: BearishCandle = close < open
Calculation: FullBody = BodyRatio >= strong body threshold
Calculation: BullRejection = LowerShadow >= BodySize * rejection wick ratio AND ClosePosition >= bull close position threshold
Calculation: BearRejection = UpperShadow >= BodySize * rejection wick ratio AND ClosePosition <= bear close position threshold
Calculation: BullMomentum = RSI(close, RSI lookback) > RSI midline AND RSI(close, RSI lookback) > RSI(close, RSI lookback)[1]
Calculation: BearMomentum = RSI(close, RSI lookback) < RSI midline AND RSI(close, RSI lookback) < RSI(close, RSI lookback)[1]
Calculation: BullLocation = NearLowerZone OR (Trend == 1 AND close > EMA(close, shorter EMA lookback))
Calculation: BearLocation = NearUpperZone OR (Trend == -1 AND close < EMA(close, shorter EMA lookback))
Calculation: BullStructure = close > LatestPivotHigh
Calculation: BearStructure = close < LatestPivotLow
Calculation: InsideBar = high[1] < high[2] AND low[1] > low[2]
Calculation: CandidateRank(direction, base, location, structure, momentum, volume, rejection) = base + (Trend == direction ? trend aligned bonus : Trend == 0 ? trend neutral bonus : trend opposed penalty) + (location ? location bonus : 0) + (structure ? structure bonus * structure weight : 0) + (momentum ? momentum bonus : momentum penalty) + (volume ? volume bonus : 0) + (rejection ? rejection bonus : 0) + MIN(MAX(SlopeStrength, 0), slope cap)
Calculation: EngulfBullRank = IF (BullishCandle AND BearishCandle[1] AND open <= close[1] AND close >= open[1] AND BodySize >= BodySize[1] * engulf body ratio) THEN CandidateRank(1, engulf base, BullLocation, BullStructure, BullMomentum, VolumeSurge, BullRejection) ELSE 0
Calculation: EngulfBearRank = IF (BearishCandle AND BullishCandle[1] AND open >= close[1] AND close <= open[1] AND BodySize >= BodySize[1] * engulf body ratio) THEN CandidateRank(-1, engulf base, BearLocation, BearStructure, BearMomentum, VolumeSurge, BearRejection) ELSE 0
Calculation: HammerRank = IF (BullishCandle AND LowerShadow >= BodySize * hammer wick ratio AND UpperShadow <= Span * hammer opposite wick fraction AND ClosePosition >= hammer close position) THEN CandidateRank(1, hammer base, BullLocation, BullStructure, BullMomentum, VolumeSurge, true) ELSE 0
Calculation: InvertedHammerRank = IF (BullishCandle AND UpperShadow >= BodySize * inverted wick ratio AND ClosePosition >= inverted close position AND NearLowerZone) THEN CandidateRank(1, inverted base, BullLocation, BullStructure, BullMomentum, VolumeSurge, true) ELSE 0
Calculation: ShootingStarRank = IF (BearishCandle AND UpperShadow >= BodySize * hammer wick ratio AND LowerShadow <= Span * hammer opposite wick fraction AND ClosePosition <= shooting star close position) THEN CandidateRank(-1, hammer base, BearLocation, BearStructure, BearMomentum, VolumeSurge, true) ELSE 0
Calculation: HangingManRank = IF (BearishCandle AND LowerShadow >= BodySize * inverted wick ratio AND NearUpperZone AND ClosePosition <= hanging man close position) THEN CandidateRank(-1, inverted base, BearLocation, BearStructure, BearMomentum, VolumeSurge, true) ELSE 0
Calculation: MorningStarRank = IF (BearishCandle[2] AND BodySize[1] / Span[1] <= star body fraction AND BullishCandle AND close > midpoint(open[2], close[2])) THEN CandidateRank(1, morning base, BullLocation, BullStructure, BullMomentum, VolumeSurge, BullRejection) ELSE 0
Calculation: EveningStarRank = IF (BullishCandle[2] AND BodySize[1] / Span[1] <= star body fraction AND BearishCandle AND close < midpoint(open[2], close[2])) THEN CandidateRank(-1, morning base, BearLocation, BearStructure, BearMomentum, VolumeSurge, BearRejection) ELSE 0
Calculation: PiercingRank = IF (BearishCandle[1] AND BullishCandle AND open < close[1] AND close > midpoint(open[1], close[1]) AND close < open[1]) THEN CandidateRank(1, piercing base, BullLocation, BullStructure, BullMomentum, VolumeSurge, BullRejection) ELSE 0
Calculation: DarkCloudRank = IF (BullishCandle[1] AND BearishCandle AND open > close[1] AND close < midpoint(open[1], close[1]) AND close > open[1]) THEN CandidateRank(-1, piercing base, BearLocation, BearStructure, BearMomentum, VolumeSurge, BearRejection) ELSE 0
Calculation: HaramiBullRank = IF (BearishCandle[1] AND BullishCandle AND high <= high[1] AND low >= low[1] AND close > open[1]) THEN CandidateRank(1, harami base, BullLocation, BullStructure, BullMomentum, VolumeSurge, BullRejection) ELSE 0
Calculation: HaramiBearRank = IF (BullishCandle[1] AND BearishCandle AND high <= high[1] AND low >= low[1] AND close < open[1]) THEN CandidateRank(-1, harami base, BearLocation, BearStructure, BearMomentum, VolumeSurge, BearRejection) ELSE 0
Calculation: InsideBreakUpRank = IF (InsideBar AND close > high[1]) THEN CandidateRank(1, inside base, close > EMA(close, shorter EMA lookback), BullStructure, BullMomentum, VolumeSurge, FullBody) ELSE 0
Calculation: InsideBreakDownRank = IF (InsideBar AND close < low[1]) THEN CandidateRank(-1, inside base, close < EMA(close, shorter EMA lookback), BearStructure, BearMomentum, VolumeSurge, FullBody) ELSE 0
Calculation: MarubozuBullRank = IF (BullishCandle AND BodyRatio >= marubozu body fraction AND ClosePosition >= marubozu bull close position AND LowerShadow <= Span * marubozu wick fraction) THEN CandidateRank(1, marubozu base, close > EMA(close, shorter EMA lookback), BullStructure, BullMomentum, VolumeSurge, FullBody) ELSE 0
Calculation: MarubozuBearRank = IF (BearishCandle AND BodyRatio >= marubozu body fraction AND ClosePosition <= marubozu bear close position AND UpperShadow <= Span * marubozu wick fraction) THEN CandidateRank(-1, marubozu base, close < EMA(close, shorter EMA lookback), BearStructure, BearMomentum, VolumeSurge, FullBody) ELSE 0
Calculation: ThreeSoldiersRank = IF (BullishCandle AND BullishCandle[1] AND BullishCandle[2] AND close > close[1] AND close[1] > close[2] AND BodyRatio >= three-candle body fraction) THEN CandidateRank(1, soldier base, close > EMA(close, shorter EMA lookback), BullStructure, BullMomentum, VolumeSurge, FullBody) ELSE 0
Calculation: ThreeCrowsRank = IF (BearishCandle AND BearishCandle[1] AND BearishCandle[2] AND close < close[1] AND close[1] < close[2] AND BodyRatio >= three-candle body fraction) THEN CandidateRank(-1, soldier base, close < EMA(close, shorter EMA lookback), BearStructure, BearMomentum, VolumeSurge, FullBody) ELSE 0
Calculation: TweezerBottomRank = IF (ABS(low - low[1]) <= ATR(ATR lookback) * tweezer tolerance AND BearishCandle[1] AND BullishCandle AND ClosePosition >= tweezer bull close position) THEN CandidateRank(1, tweezer base, BullLocation, BullStructure, BullMomentum, VolumeSurge, BullRejection) ELSE 0
Calculation: TweezerTopRank = IF (ABS(high - high[1]) <= ATR(ATR lookback) * tweezer tolerance AND BullishCandle[1] AND BearishCandle AND ClosePosition <= tweezer bear close position) THEN CandidateRank(-1, tweezer base, BearLocation, BearStructure, BearMomentum, VolumeSurge, BearRejection) ELSE 0
Calculation: RailBullRank = IF (BearishCandle[1] AND BullishCandle AND BodyRatio >= rail body fraction AND ABS(BodySize - BodySize[1]) <= ATR(ATR lookback) * rail tolerance AND close > high[1]) THEN CandidateRank(1, rail base, close > EMA(close, shorter EMA lookback), BullStructure, BullMomentum, VolumeSurge, FullBody) ELSE 0
Calculation: RailBearRank = IF (BullishCandle[1] AND BearishCandle AND BodyRatio >= rail body fraction AND ABS(BodySize - BodySize[1]) <= ATR(ATR lookback) * rail tolerance AND close < low[1]) THEN CandidateRank(-1, rail base, close < EMA(close, shorter EMA lookback), BearStructure, BearMomentum, VolumeSurge, FullBody) ELSE 0
Calculation: ReclaimRank = IF (low < LatestPivotLow AND close > LatestPivotLow AND BullRejection) THEN CandidateRank(1, reclaim base, true, true, BullMomentum, VolumeSurge, true) ELSE 0
Calculation: RejectRank = IF (high > LatestPivotHigh AND close < LatestPivotHigh AND BearRejection) THEN CandidateRank(-1, reclaim base, true, true, BearMomentum, VolumeSurge, true) ELSE 0
Calculation: TopRank = MAX(EngulfBullRank, EngulfBearRank, HammerRank, InvertedHammerRank, ShootingStarRank, HangingManRank, MorningStarRank, EveningStarRank, PiercingRank, DarkCloudRank, HaramiBullRank, HaramiBearRank, InsideBreakUpRank, InsideBreakDownRank, MarubozuBullRank, MarubozuBearRank, ThreeSoldiersRank, ThreeCrowsRank, TweezerBottomRank, TweezerTopRank, RailBullRank, RailBearRank, ReclaimRank, RejectRank)
Calculation: TopDirection = 1 if the first rank in the order EngulfBullRank, EngulfBearRank, HammerRank, InvertedHammerRank, ShootingStarRank, HangingManRank, MorningStarRank, EveningStarRank, PiercingRank, DarkCloudRank, HaramiBullRank, HaramiBearRank, InsideBreakUpRank, InsideBreakDownRank, MarubozuBullRank, MarubozuBearRank, ThreeSoldiersRank, ThreeCrowsRank, TweezerBottomRank, TweezerTopRank, RailBullRank, RailBearRank, ReclaimRank, RejectRank that equals TopRank is bullish, otherwise -1
Calculation: Signal = closed bar AND NOT (Signal[1] OR Signal[2] OR ... OR Signal[cooldown bars]) AND TopRank >= minimum accepted score
Long: Signal AND TopDirection == 1
Short: Signal AND TopDirection == -1
Long: closed bar AND close > LatestPivotHigh AND close[1] <= LatestPivotHigh
Short: closed bar AND close < LatestPivotLow AND close[1] >= LatestPivotLow