Calculation: VolumeZ = (volume - SMA(volume, volume lookback)) / STDEV(volume, volume lookback)
Calculation: RangeGate = true range >= ATR(ATR lookback) * ATR multiplier
Calculation: AdaptiveAverage = AdaptiveAverage[1] + SC * (close - AdaptiveAverage[1]), where SC = (ER * (2/(shorter smoothing period + 1) - 2/(longer smoothing period + 1)) + 2/(longer smoothing period + 1))^2 and ER = abs(close - close[ER lookback]) / SUM(true range, ER lookback)
Calculation: BullishTrend = close > SMA(close, shorter SMA lookback) AND SMA(close, shorter SMA lookback) > SMA(close, longer SMA lookback)
Calculation: BearishTrend = close < SMA(close, shorter SMA lookback) AND SMA(close, shorter SMA lookback) < SMA(close, longer SMA lookback)
Calculation: HtfBullish = chart timeframe shorter than T1 AND close(T1, last completed bar) > SMA(close, shorter SMA lookback, T1, last completed bar)
Calculation: HtfBearish = chart timeframe shorter than T1 AND close(T1, last completed bar) < SMA(close, shorter SMA lookback, T1, last completed bar)
Calculation: LongPoints = IF(BullishTrend, trend weight, 0) + IF(HtfBullish, HTF weight, 0) + IF(VolumeZ >= signal volume Z threshold, signal volume weight, 0) + IF(VolumeZ >= major volume Z threshold, major volume weight, 0) + IF(RangeGate, range weight, 0) + IF(close > AdaptiveAverage, adaptive weight, 0) + IF(close - low > high - close, bias weight, 0) + IF(close > open, candle weight, 0)
Calculation: ShortPoints = IF(BearishTrend, trend weight, 0) + IF(HtfBearish, HTF weight, 0) + IF(VolumeZ >= signal volume Z threshold, signal volume weight, 0) + IF(VolumeZ >= major volume Z threshold, major volume weight, 0) + IF(RangeGate, range weight, 0) + IF(close < AdaptiveAverage, adaptive weight, 0) + IF(high - close > close - low, bias weight, 0) + IF(close < open, candle weight, 0)
Calculation: BarsSinceEntry = bars since the most recent prior bar on which LongEntry or ShortEntry is true
Calculation: LongEntry = bar closed AND LongPoints > ShortPoints AND LongPoints >= minimum points AND HtfBullish AND RangeGate AND VolumeZ >= signal volume Z threshold AND close > AdaptiveAverage AND BullishTrend AND BarsSinceEntry >= cooldown length
Calculation: ShortEntry = bar closed AND ShortPoints > LongPoints AND ShortPoints >= minimum points AND HtfBearish AND RangeGate AND VolumeZ >= signal volume Z threshold AND close < AdaptiveAverage AND BearishTrend AND BarsSinceEntry >= cooldown length
Calculation: MacdHistogram = MACD histogram(close, shorter MACD lookback, longer MACD lookback, signal lookback)
Calculation: UpsideExhaustion = bar closed AND RSI(close, RSI lookback) > overbought level AND MacdHistogram < MacdHistogram[1] AND MacdHistogram[1] > 0
Calculation: DownsideExhaustion = bar closed AND RSI(close, RSI lookback) < oversold level AND MacdHistogram > MacdHistogram[1] AND MacdHistogram[1] < 0
Calculation: BearishDivergence = bar closed AND pivot high(high, pivot left bars, pivot right bars) is confirmed on this bar AND high[pivot right bars] > high at previous pivot high bar AND RSI(close, RSI lookback)[pivot right bars] < RSI(close, RSI lookback) at previous pivot high bar
Calculation: BullishDivergence = bar closed AND pivot low(low, pivot left bars, pivot right bars) is confirmed on this bar AND low[pivot right bars] < low at previous pivot low bar AND RSI(close, RSI lookback)[pivot right bars] > RSI(close, RSI lookback) at previous pivot low bar
Long: LongEntry
Short: ShortEntry
Long: BullishTrend AND NOT UpsideExhaustion AND NOT DownsideExhaustion
Short: BearishTrend AND NOT UpsideExhaustion AND NOT DownsideExhaustion
Exit: long, UpsideExhaustion OR BearishDivergence
Exit: short, DownsideExhaustion OR BullishDivergence