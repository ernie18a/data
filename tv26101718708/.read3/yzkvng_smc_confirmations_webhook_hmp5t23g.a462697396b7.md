Calculation: TrendSlope = EMA(close, trend lookback) - EMA(close, trend lookback)[slope lookback]
Calculation: TrendUp = ADX(adx lookback) >= adx threshold AND TrendSlope > ATR(atr lookback) * trend slope multiple
Calculation: TrendDown = ADX(adx lookback) >= adx threshold AND TrendSlope < -ATR(atr lookback) * trend slope multiple
Calculation: RangeMarket = Highest(high, range lookback) - Lowest(low, range lookback) > ATR(atr lookback) * range width multiple AND NOT TrendUp AND NOT TrendDown
Calculation: LowerShadow = min(open, close) - low
Calculation: UpperShadow = high - max(open, close)
Calculation: BodySize = ABS(close - open)
Calculation: UpClose = close > open AND close > close[1]
Calculation: DownClose = close < open AND close < close[1]
Calculation: LongTriggerCandle = if trigger type selects close then UpClose; if trigger type selects engulfing then close > open AND close[1] < open[1] AND close > open[1] AND open < close[1]; if trigger type selects pin bar then LowerShadow > BodySize * pin wick multiple AND UpperShadow < BodySize * pin opposite wick multiple
Calculation: ShortTriggerCandle = if trigger type selects close then DownClose; if trigger type selects engulfing then close < open AND close[1] > open[1] AND close < open[1] AND open > close[1]; if trigger type selects pin bar then UpperShadow > BodySize * pin wick multiple AND LowerShadow < BodySize * pin opposite wick multiple
Calculation: LongZoneHit = low <= last PivotLow(low, pivot span, pivot span) + ATR(atr lookback) * zone buffer multiple AND low >= last PivotLow(low, pivot span, pivot span) - ATR(atr lookback) * zone margin multiple
Calculation: ShortZoneHit = high >= last PivotHigh(high, pivot span, pivot span) - ATR(atr lookback) * zone buffer multiple AND high <= last PivotHigh(high, pivot span, pivot span) + ATR(atr lookback) * zone margin multiple
Calculation: LongZoneRun = if LongZoneHit then LongZoneRun[1] + 1 else 0
Calculation: ShortZoneRun = if ShortZoneHit then ShortZoneRun[1] + 1 else 0
Calculation: LongTriggerLatched = (LongTriggerLatched[1] AND LongZoneHit) OR (LongZoneHit AND LongZoneRun >= wait bars AND LongTriggerCandle)
Calculation: ShortTriggerLatched = (ShortTriggerLatched[1] AND ShortZoneHit) OR (ShortZoneHit AND ShortZoneRun >= wait bars AND ShortTriggerCandle)
Calculation: LongConfirmations = count of true among: UpClose; volume > SMA(volume, volume lookback) * volume multiple; RSI(close, rsi lookback) >= rsi bull floor AND RSI(close, rsi lookback) < rsi overbought; LowerShadow >= wick ratio * (high - low); no i from 1 to opposing bar count has close[i] < open[i] AND ABS(close[i] - open[i]) > ATR(atr lookback)[i] * opposing body multiple
Calculation: ShortConfirmations = count of true among: DownClose; volume > SMA(volume, volume lookback) * volume multiple; RSI(close, rsi lookback) <= rsi bear ceiling AND RSI(close, rsi lookback) > rsi oversold; UpperShadow >= wick ratio * (high - low); no i from 1 to opposing bar count has close[i] > open[i] AND ABS(close[i] - open[i]) > ATR(atr lookback)[i] * opposing body multiple
Long: LongTriggerLatched AND LongConfirmations >= min confirmations AND (TrendUp OR (both a pivot high and a pivot low have occurred AND TrendSlope > 0))
Short: ShortTriggerLatched AND ShortConfirmations >= min confirmations AND (TrendDown OR (both a pivot high and a pivot low have occurred AND TrendSlope < 0))
Long: close <= Lowest(low, range lookback) + ATR(atr lookback) * range touch multiple AND LongConfirmations >= min confirmations AND RangeMarket
Short: close >= Highest(high, range lookback) - ATR(atr lookback) * range touch multiple AND ShortConfirmations >= min confirmations AND RangeMarket