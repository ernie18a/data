Calculation: AtrValue = ATR(ATR length)
Calculation: AtrExpansion = AtrValue > SMA(AtrValue, ATR average length) * ATR expansion multiple
Calculation: FastEma = EMA(close, fast EMA length)
Calculation: SlowEma = EMA(close, slow EMA length)
Calculation: AdxValue = ADX(ADX length)
Calculation: RsiValue = RSI(close, RSI length)
Calculation: MacdHist = MACD histogram(close, MACD fast length, MACD slow length, MACD signal length)
Calculation: BbWidth = BollingerBandWidth(close, BB length, band multiplier)
Calculation: HtfRsi = RSI(close, HTF RSI length) on T1 bars, last completed T1 bar
Calculation: HtfMacdHist = MACD histogram(close, HTF MACD fast length, HTF MACD slow length, HTF MACD signal length) on T1 bars, last completed T1 bar
Calculation: HtfBull = HtfMacdHist > 0 AND HtfRsi > HTF RSI midline
Calculation: HtfBear = HtfMacdHist < 0 AND HtfRsi < HTF RSI midline
Calculation: TrendingRegime = AdxValue > trending ADX threshold AND ABS(FastEma - SlowEma) > trend spread multiple * AtrValue AND (HtfBull OR HtfBear)
Calculation: RangeRegime = AdxValue < range ADX threshold AND (Highest(high, range lookback) - Lowest(low, range lookback)) / close < range fraction AND NOT HtfBull AND NOT HtfBear
Calculation: VolatileRegime = BbWidth > SMA(BbWidth, BB width average length) * volatile BB width multiple AND AtrExpansion AND (HtfRsi > HTF RSI overbought level OR HtfRsi < HTF RSI oversold level) AND NOT TrendingRegime AND NOT RangeRegime
Calculation: VolumeSpike = volume > SMA(volume, volume average length) * volume spike multiple
Calculation: NearSupport = low <= Lowest(low, S/R lookback) * (1 + support tolerance)
Calculation: NearResistance = high >= Highest(high, S/R lookback) * (1 - resistance tolerance)
Calculation: BullishEngulfingPattern = close[1] < open[1] AND close > open AND close > open[1] AND open < close[1] AND NearSupport AND VolumeSpike
Calculation: HammerPattern = (high - low) > candle range multiple * ABS(open - close) AND (close - low) > close position fraction * (high - low) AND NearSupport AND VolumeSpike
Calculation: MorningStarPattern = close[2] < open[2] AND ABS(close[1] - open[1]) < small body fraction * (high[1] - low[1]) AND close > open AND close > (open[2] + close[2]) / 2 AND NearSupport AND VolumeSpike
Calculation: PiercingPattern = close[1] < open[1] AND close > open AND close > (open[1] + close[1]) / 2 AND open < close[1] AND NearSupport AND VolumeSpike
Calculation: DoubleBottomPattern = low < low[1] AND low[1] > low[2] AND low[2] < low[3] AND close > open AND NearSupport AND VolumeSpike
Calculation: BearishEngulfingPattern = close[1] > open[1] AND close < open AND close < open[1] AND open > close[1] AND NearResistance AND VolumeSpike
Calculation: ShootingStarPattern = (high - low) > candle range multiple * ABS(open - close) AND (high - close) > close position fraction * (high - low) AND NearResistance AND VolumeSpike
Calculation: EveningStarPattern = close[2] > open[2] AND ABS(close[1] - open[1]) < small body fraction * (high[1] - low[1]) AND close < open AND close < (open[2] + close[2]) / 2 AND NearResistance AND VolumeSpike
Calculation: DarkCloudPattern = close[1] > open[1] AND close < open AND close < (open[1] + close[1]) / 2 AND open > close[1] AND NearResistance AND VolumeSpike
Calculation: DoubleTopPattern = high > high[1] AND high[1] < high[2] AND high[2] > high[3] AND close < open AND NearResistance AND VolumeSpike
Calculation: BullishScore = (BullishEngulfingPattern ? engulfing weight : 0) + (HammerPattern ? (RangeRegime ? candle weight in Range : candle weight outside Range) : 0) + (MorningStarPattern ? star weight : 0) + (PiercingPattern ? piercing weight : 0) + (DoubleBottomPattern ? (VolatileRegime ? double weight in Volatile : double weight outside Volatile) : 0) + (FastEma > SlowEma ? trend weight : 0) + (RsiValue < RSI oversold level ? RSI weight : 0) + (MacdHist > 0 ? MACD weight : 0) + (AtrExpansion ? expansion weight : 0) + ((HtfBull AND HtfRsi < HTF RSI overbought level) ? HTF confirmation weight : 0)
Calculation: BearishScore = (BearishEngulfingPattern ? engulfing weight : 0) + (ShootingStarPattern ? (RangeRegime ? candle weight in Range : candle weight outside Range) : 0) + (EveningStarPattern ? star weight : 0) + (DarkCloudPattern ? piercing weight : 0) + (DoubleTopPattern ? (VolatileRegime ? double weight in Volatile : double weight outside Volatile) : 0) + (FastEma < SlowEma ? trend weight : 0) + (RsiValue > RSI overbought level ? RSI weight : 0) + (MacdHist < 0 ? MACD weight : 0) + (AtrExpansion ? expansion weight : 0) + ((HtfBear AND HtfRsi > HTF RSI oversold level) ? HTF confirmation weight : 0)
Calculation: StopDistance = (ATR stop switch ? stop ATR multiple * AtrValue : fixed stop points)
Calculation: LongEntryStop = Lowest(low, swing lookback) - StopDistance, on the bar where the long entry is placed
Calculation: LongTarget = entry price + reward multiple * (entry price - LongEntryStop)
Calculation: LongTrailStop = LongEntryStop on the entry bar, otherwise (close > trail activation fraction * LongTarget ? MAX(LongTrailStop[1], close - trailing ATR multiple * AtrValue) : LongTrailStop[1])
Calculation: ShortEntryStop = Highest(high, swing lookback) + StopDistance, on the bar where the short entry is placed
Calculation: ShortTarget = entry price - reward multiple * (ShortEntryStop - entry price)
Calculation: ShortTrailStop = ShortEntryStop on the entry bar, otherwise (close < trail activation fraction * ShortTarget ? MIN(ShortTrailStop[1], close + trailing ATR multiple * AtrValue) : ShortTrailStop[1])
Long: BullishScore >= score threshold AND position side is not Long
Short: BearishScore >= score threshold AND position side is not Short
Exit: long, low <= LongTrailStop[1]
Exit: long, high >= LongTarget
Exit: long, close < LongEntryStop
Exit: short, high >= ShortTrailStop[1]
Exit: short, low <= ShortTarget
Exit: short, close > ShortEntryStop