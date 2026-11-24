Calculation: TF state(T) = 1 if EMA(close, fast length) > EMA(close, slow length) AND close > EMA(close, fast length); -1 if EMA(close, fast length) < EMA(close, slow length) AND close < EMA(close, fast length); else 0; computed on T bars and taken from the completed T bar before the last completed T bar
Calculation: BullTF = count over T1..T4 of [TF state = 1]
Calculation: BearTF = count over T1..T4 of [TF state = -1]
Calculation: EmaUp = EMA(close, fast length) > EMA(close, slow length) AND close > EMA(close, fast length)
Calculation: EmaDown = EMA(close, fast length) < EMA(close, slow length) AND close < EMA(close, fast length)
Calculation: ATRTrail = ATRTrail[1] moved toward close by L, where L = ATR(atr length) * clamp(trail multiple + (100 - QualityScore) / 100 * quality scale, min factor, max factor); ATRTrail = max(ATRTrail[1], close - L) if close > ATRTrail[1] AND close[1] > ATRTrail[1]; min(ATRTrail[1], close + L) if close < ATRTrail[1] AND close[1] < ATRTrail[1]; close - L if close > ATRTrail[1]; else close + L; initial ATRTrail[1] = close - L
Calculation: QualityScore = clamp(0 to 100, (EfficiencyRatio(close, quality length) * 100 + min(ADX(adx length, adx smoothing) / adx scale * 100, 100) + max(SMA(MomUp, quality length), SMA(MomDown, quality length)) * 100 + max(0, 100 - abs(ATR(atr length) / SMA(ATR(atr length), ATR average length) - 1) * stability scale)) / 4)
Calculation: Uptrend = EmaUp AND close > ATRTrail AND ADX(adx length, adx smoothing) >= ADX minimum AND BullTF >= trend TF minimum
Calculation: Downtrend = EmaDown AND close < ATRTrail AND ADX(adx length, adx smoothing) >= ADX minimum AND BearTF >= trend TF minimum
Calculation: Momentum = LinReg(close - (DonchianMidline(squeeze length) + SMA(close, squeeze length)) / 2, squeeze length, offset 0)
Calculation: MomUp = Momentum > Momentum[1]
Calculation: MomDown = Momentum < Momentum[1]
Calculation: MomBullish = Momentum > EMA(Momentum, smoothing length) AND MomUp
Calculation: MomBearish = Momentum < EMA(Momentum, smoothing length) AND MomDown
Calculation: Squeeze = BollingerBands(close, squeeze length, BB multiplier) lies inside KeltnerChannel(close, squeeze length, ATR(atr length), KC multiplier), i.e. BB upper < KC upper AND BB lower > KC lower
Calculation: SqueezeRecent = Squeeze is true on the current bar or on any of the previous squeeze window bars
Calculation: SqueezeUp = ((NOT Squeeze AND Squeeze[1]) OR SqueezeRecent) AND MomBullish
Calculation: SqueezeDown = ((NOT Squeeze AND Squeeze[1]) OR SqueezeRecent) AND MomBearish
Calculation: Flux = EMA(close - close[1], flux length) / ATR(atr length) * 100, or 0 if ATR <= 0
Calculation: FluxUp = Flux > EMA(Flux, flux signal length) AND Flux > 0
Calculation: FluxDown = Flux < EMA(Flux, flux signal length) AND Flux < 0
Calculation: SwingHigh = high of the latest bar b whose high is the maximum over bars b - swing length to b + swing length, known from bar b + swing length onward
Calculation: SwingLow = low of the latest bar b whose low is the minimum over bars b - swing length to b + swing length, known from bar b + swing length onward
Calculation: BreakUp = bar closed AND close > SwingHigh AND SwingHigh differs from the swing of the previous BreakUp AND NOT (close < SwingLow AND SwingLow differs from the swing of the previous BreakDown AND StructState[1] = 1)
Calculation: BreakDown = bar closed AND close < SwingLow AND SwingLow differs from the swing of the previous BreakDown AND NOT (close > SwingHigh AND SwingHigh differs from the swing of the previous BreakUp AND StructState[1] <= 0)
Calculation: StructState = 1 if BreakUp; -1 if BreakDown; else StructState[1]; initially 0
Calculation: ReversalUp = BreakUp AND StructState[1] <= 0
Calculation: TrendBreakUp = BreakUp AND StructState[1] = 1
Calculation: ReversalDown = BreakDown AND StructState[1] >= 0
Calculation: TrendBreakDown = BreakDown AND StructState[1] = -1
Calculation: BullOBLive = the last bearish candle (its high and low) at the latest ReversalUp or TrendBreakUp, and no close below its low since
Calculation: BullOBTouch = BullOBLive AND low <= that candle high AND close >= that candle low
Calculation: BearOBLive = the last bullish candle (its high and low) at the latest ReversalDown or TrendBreakDown, and no close above its high since
Calculation: BearOBTouch = BearOBLive AND high >= that candle low AND close <= that candle high
Calculation: FibSide = 1 on ReversalUp or TrendBreakUp; -1 on ReversalDown or TrendBreakDown; else FibSide[1]; initially 0
Calculation: FibTop = highest high since the latest up break (inclusive) if FibSide = 1; SwingHigh at the latest down break if FibSide = -1
Calculation: FibBottom = SwingLow at the latest up break if FibSide = 1; lowest low since the latest down break (inclusive) if FibSide = -1
Calculation: FibMidLevel = FibTop - mid fraction * (FibTop - FibBottom) if FibSide = 1; FibBottom + mid fraction * (FibTop - FibBottom) if FibSide = -1
Calculation: InFibZone = FibTop > FibBottom AND FibSide != 0 AND high >= lower zone bound AND low <= upper zone bound, where zone bounds are the levels at zone-from and zone-to fractions of (FibTop - FibBottom) measured from FibTop if FibSide = 1 or from FibBottom if FibSide = -1
Calculation: FibLongConf = fib filter enabled AND FibSide = 1 AND InFibZone AND (SweepDown OR BullOBTouch OR MomUp OR close > FibMidLevel)
Calculation: FibShortConf = fib filter enabled AND FibSide = -1 AND InFibZone AND (SweepUp OR BearOBTouch OR MomDown OR close < FibMidLevel)
Calculation: SweepDown = (SwingLow exists AND low < SwingLow - ATR(atr length) * sweep tolerance AND close > SwingLow AND open > SwingLow) OR (low < DonchianLow(range length, prior bars) AND close > DonchianLow(range length, prior bars) AND VolumeSoft)
Calculation: SweepUp = (SwingHigh exists AND high > SwingHigh + ATR(atr length) * sweep tolerance AND close < SwingHigh AND open < SwingHigh) OR (high > DonchianHigh(range length, prior bars) AND close < DonchianHigh(range length, prior bars) AND VolumeSoft)
Calculation: VolumeFull = volume > SMA(volume, volume average length) * volume multiplier
Calculation: VolumeSoft = volume > SMA(volume, volume average length) * soft volume multiplier
Calculation: RangeBreakUp = close > DonchianHigh(range length, prior bars) AND VolumeSoft AND (SqueezeRecent OR close[1] <= DonchianHigh(range length, prior bars))
Calculation: RangeBreakDown = close < DonchianLow(range length, prior bars) AND VolumeSoft AND (SqueezeRecent OR close[1] >= DonchianLow(range length, prior bars))
Calculation: RetestUp = the first bar after the latest RangeBreakUp, within retest window bars, with low <= that break's DonchianHigh level and close > that level
Calculation: RetestDown = the first bar after the latest RangeBreakDown, within retest window bars, with high >= that break's DonchianLow level and close < that level
Calculation: BullCandle = BullPin OR BullEngulf, where BullPin = close > open AND (min(open, close) - low) > wick ratio * abs(close - open), and BullEngulf = close > open AND close[1] < open[1] AND close >= open[1] AND open <= close[1]
Calculation: BearCandle = BearPin OR BearEngulf, where BearPin = close < open AND (high - max(open, close)) > wick ratio * abs(close - open), and BearEngulf = close < open AND close[1] > open[1] AND close <= open[1] AND open >= close[1]
Calculation: BullDiv = the latest pivot low (pivot strength = swing length) is below the previous pivot low AND RSI(close, rsi length) at the latest pivot bar is above its value at the previous pivot bar
Calculation: BearDiv = the latest pivot high is above the previous pivot high AND RSI(close, rsi length) at the latest pivot bar is below its value at the previous pivot bar
Calculation: PreNews = news mode enabled AND for some enabled scheduled news time t: t - before minutes <= time < t
Calculation: PostNews = news mode enabled AND for some enabled scheduled news time t: t <= time <= t + after minutes
Calculation: NewsBlock = news blocking enabled AND PreNews
Calculation: NewsUp = PostNews AND close > open AND close > close[1] AND volume > SMA(volume, volume average length)
Calculation: NewsDown = PostNews AND close < open AND close < close[1] AND volume > SMA(volume, volume average length)
Calculation: EntryThreshold = entry threshold + (political-risk flag ? risk adder : 0)
Calculation: PreThreshold = pre-entry threshold + (political-risk flag ? risk adder : 0)
Calculation: LeadThreshold = lead margin + (political-risk flag ? lead adder : 0)
Calculation: ReentryOpenLong = no LongEntry yet, or bars since the last LongEntry >= ceil(reentry hours * 3600 / chart timeframe seconds)
Calculation: ReentryOpenShort = no ShortEntry yet, or bars since the last ShortEntry >= ceil(reentry hours * 3600 / chart timeframe seconds)
Calculation: OverextendedLong = Uptrend AND close > ATRTrail + ATR(atr length) * late distance AND RSI(close, rsi length) > overextended RSI high AND QualityScore < strong quality
Calculation: OverextendedShort = Downtrend AND close < ATRTrail - ATR(atr length) * late distance AND RSI(close, rsi length) < overextended RSI low AND QualityScore < strong quality
Calculation: PullbackUp = pullback enabled AND Uptrend AND ReentryOpenLong AND low <= EMA(close, fast length) + ATR(atr length) * pullback zone AND close > EMA(close, fast length) AND close > open AND MomUp AND BullScore >= PreThreshold AND BearTF <= against limit AND NOT OverextendedLong
Calculation: PullbackDown = pullback enabled AND Downtrend AND ReentryOpenShort AND high >= EMA(close, fast length) - ATR(atr length) * pullback zone AND close < EMA(close, fast length) AND close < open AND MomDown AND BearScore >= PreThreshold AND BullTF <= against limit AND NOT OverextendedShort
Calculation: ContinuationUp = Uptrend AND ReentryOpenLong AND close > highest high of prior continuation lookback bars AND VolumeSoft AND BullScore >= EntryThreshold AND BullTF >= MTF minimum AND NOT OverextendedLong AND QualityScore >= weak quality
Calculation: ContinuationDown = Downtrend AND ReentryOpenShort AND close < lowest low of prior continuation lookback bars AND VolumeSoft AND BearScore >= EntryThreshold AND BearTF >= MTF minimum AND NOT OverextendedShort AND QualityScore >= weak quality
Calculation: ScoutUp = pre-entry enabled AND (SqueezeUp AND FluxUp OR SweepDown AND (MomUp OR BullCandle) OR BullDiv AND MomUp OR Momentum crosses above EMA(Momentum, smoothing length) AND RSI(close, rsi length) < scout RSI) AND NOT (Downtrend OR BearTF >= context count) AND MomBullish AND FluxUp AND VolumeSoft AND BearTF <= against limit
Calculation: ScoutDown = pre-entry enabled AND (SqueezeDown AND FluxDown OR SweepUp AND (MomDown OR BearCandle) OR BearDiv AND MomDown OR Momentum crosses below EMA(Momentum, smoothing length) AND RSI(close, rsi length) > scout RSI) AND NOT (Uptrend OR BullTF >= context count) AND MomBearish AND FluxDown AND VolumeSoft AND BullTF <= against limit
Calculation: BullScore = clamp(0 to 100, sum of: w(EmaUp)*EmaUp + w(trail)*(close > ATRTrail) + w(ADX)*(ADX >= ADX minimum) + w(VolumeFull)*VolumeFull + w(VolumeSoft)*(VolumeSoft AND NOT VolumeFull) + w(bull TF)*BullTF + w(SqueezeUp)*SqueezeUp + w(FluxUp)*FluxUp + w(SweepDown)*SweepDown + w(BullDiv)*BullDiv + w(BullCandle)*BullCandle + w(RangeBreakUp)*RangeBreakUp + w(RetestUp)*RetestUp + (ReversalUp ? w(high) : TrendBreakUp ? w(mid) : StructState = 1 ? w(low) : 0) + (FibLongConf ? w(high) : FibSide = 1 AND close <= FibMidLevel ? w(mid) : 0) + (BullOBTouch ? w(high) : BullOBLive AND close > live bull OB high ? w(low) : 0) + (QualityScore >= strong quality ? w(high) : QualityScore >= weak quality ? w(mid) : 0) + w(NewsUp)*NewsUp - w(PreNews)*PreNews - w(late fib)*(FibSide = 1 AND close > FibMidLevel AND QualityScore < strong quality))
Calculation: BearScore = clamp(0 to 100, sum of: w(EmaDown)*EmaDown + w(trail)*(close < ATRTrail) + w(ADX)*(ADX >= ADX minimum) + w(VolumeFull)*VolumeFull + w(VolumeSoft)*(VolumeSoft AND NOT VolumeFull) + w(bear TF)*BearTF + w(SqueezeDown)*SqueezeDown + w(FluxDown)*FluxDown + w(SweepUp)*SweepUp + w(BearDiv)*BearDiv + w(BearCandle)*BearCandle + w(RangeBreakDown)*RangeBreakDown + w(RetestDown)*RetestDown + (ReversalDown ? w(high) : TrendBreakDown ? w(mid) : StructState = -1 ? w(low) : 0) + (FibShortConf ? w(high) : FibSide = -1 AND close >= FibMidLevel ? w(mid) : 0) + (BearOBTouch ? w(high) : BearOBLive AND close < live bear OB low ? w(low) : 0) + (QualityScore >= strong quality ? w(high) : QualityScore >= weak quality ? w(mid) : 0) + w(NewsDown)*NewsDown - w(PreNews)*PreNews - w(late fib)*(FibSide = -1 AND close < FibMidLevel AND QualityScore < strong quality))
Calculation: LongEntry = bar closed AND no long position AND NOT NewsBlock AND NOT OverextendedLong AND ((BullScore >= EntryThreshold AND BullScore >= BearScore + LeadThreshold AND BullTF >= MTF minimum AND ((safe entries enabled AND (RetestUp OR BullOBTouch OR FibLongConf OR PullbackUp OR (SweepDown AND BullCandle AND BearTF <= against limit))) OR (aggressive entries enabled AND (RangeBreakUp OR TrendBreakUp OR ReversalUp OR ScoutUp OR ContinuationUp OR NewsUp)))) OR (ScoutUp AND BullScore >= PreThreshold AND BullScore >= BearScore + max(LeadThreshold - pre-lead reduction, 0) AND BearTF <= against limit) OR PullbackUp OR ContinuationUp)
Calculation: ShortEntry = bar closed AND no short position AND NOT NewsBlock AND NOT OverextendedShort AND ((BearScore >= EntryThreshold AND BearScore >= BullScore + LeadThreshold AND BearTF >= MTF minimum AND ((safe entries enabled AND (RetestDown OR BearOBTouch OR FibShortConf OR PullbackDown OR (SweepUp AND BearCandle AND BullTF <= against limit))) OR (aggressive entries enabled AND (RangeBreakDown OR TrendBreakDown OR ReversalDown OR ScoutDown OR ContinuationDown OR NewsDown)))) OR (ScoutDown AND BearScore >= PreThreshold AND BearScore >= BullScore + max(LeadThreshold - pre-lead reduction, 0) AND BullTF <= against limit) OR PullbackDown OR ContinuationDown)
Long: LongEntry
Short: ShortEntry
Calculation: LongStop = max(entry - ATR(atr length, measured on entry bar) * stop multiple, SwingLow - ATR(atr length, on entry bar) * stop buffer if swing stop enabled AND SwingLow < entry, live bull OB low - ATR(atr length, on entry bar) * stop buffer if swing stop enabled AND BullOBLive AND its low < entry)
Calculation: ShortStop = min(entry + ATR(atr length, measured on entry bar) * stop multiple, SwingHigh + ATR(atr length, on entry bar) * stop buffer if swing stop enabled AND SwingHigh > entry, live bear OB high + ATR(atr length, on entry bar) * stop buffer if swing stop enabled AND BearOBLive AND its high > entry)
Exit: long, bar closed AND (close < ATRTrail OR close < EMA(close, slow length) OR close <= (break-even enabled AND high >= entry + (entry - LongStop) * (dynamic targets enabled ? (QualityScore on entry bar >= strong quality ? strong-quality ratio : QualityScore on entry bar >= weak quality ? weak-quality ratio : low-quality ratio) : fixed ratio) ? entry : LongStop) OR BearScore > BullScore + exit margin OR (Uptrend AND (RSI(close, rsi length) > exhaust RSI high OR (QualityScore < QualityScore[1] AND QualityScore < weak quality AND MomDown)) AND close > EMA(close, fast length) + ATR(atr length) * exhaust distance AND NOT VolumeFull))
Exit: short, bar closed AND (close > ATRTrail OR close > EMA(close, slow length) OR close >= (break-even enabled AND low <= entry - (ShortStop - entry) * (dynamic targets enabled ? (QualityScore on entry bar >= strong quality ? strong-quality ratio : QualityScore on entry bar >= weak quality ? weak-quality ratio : low-quality ratio) : fixed ratio) ? entry : ShortStop) OR BullScore > BearScore + exit margin OR (Downtrend AND (RSI(close, rsi length) < exhaust RSI low OR (QualityScore < QualityScore[1] AND QualityScore < weak quality AND MomUp)) AND close < EMA(close, fast length) - ATR(atr length) * exhaust distance AND NOT VolumeFull))
Long: SweepDown OR RangeBreakUp OR Uptrend OR StructState = 1 OR BullOBTouch OR FibLongConf OR NewsUp OR close > ATRTrail
Short: SweepUp OR RangeBreakDown OR Downtrend OR StructState = -1 OR BearOBTouch OR FibShortConf OR NewsDown OR close < ATRTrail