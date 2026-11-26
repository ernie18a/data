Calculation: VolatilityRatio = ATR(ATR length) / SMA(ATR(ATR length), ATR average length)
Calculation: ProfitScale = max(lower scale bound, min(upper profit scale bound, 1 + scale factor * (VolatilityRatio - 1)))
Calculation: StopScale = max(lower scale bound, min(upper stop scale bound, 1 + scale factor * (VolatilityRatio - 1)))
Calculation: TickOffset(ticks) = ticks * tick size / point value
Calculation: StopOffset = min(ATR(ATR length) * stop ATR multiplier, stop cap ticks * tick size) * StopScale / point value
Calculation: HighVolume = volume >= volume threshold multiple * SMA(volume, volume lookback)
Calculation: VolumePoints = high-volume points if HighVolume, else above-average volume points if volume > SMA(volume, volume lookback), else 0
Calculation: VolatilityPoints = trending volatility points if ADX(ADX length) > ADX trend threshold, else choppy volatility points if ADX(ADX length) < ADX chop threshold, else neutral volatility points
Calculation: TrendPointsLong = if ADX(ADX length) > ADX trend threshold then (strong trend points if +DI(ADX length) > -DI(ADX length), else 0), else if ADX(ADX length) > ADX chop threshold then (weak trend points if +DI(ADX length) > -DI(ADX length), else 0), else 0
Calculation: TrendPointsShort = if ADX(ADX length) > ADX trend threshold then (strong trend points if -DI(ADX length) > +DI(ADX length), else 0), else if ADX(ADX length) > ADX chop threshold then (weak trend points if -DI(ADX length) > +DI(ADX length), else 0), else 0
Calculation: MacdBullish = MACD(close, MACD fast length, MACD slow length, MACD signal length) line crosses above its signal line
Calculation: MacdBearish = MACD(close, MACD fast length, MACD slow length, MACD signal length) line crosses below its signal line
Calculation: TrendUp = TEMA(close, shorter lookback) > SMMA(close, longer lookback)
Calculation: MomentumPointsLong = both momentum points if MacdBullish AND TrendUp, else single momentum points if MacdBullish OR TrendUp, else 0
Calculation: MomentumPointsShort = both momentum points if MacdBearish AND NOT TrendUp, else single momentum points if MacdBearish OR NOT TrendUp, else 0
Calculation: PriorLowestLow = Lowest(low, prior-bars lookback)[1]
Calculation: PriorHighestHigh = Highest(high, prior-bars lookback)[1]
Calculation: PriorBarMidpoint = (high[1] + low[1]) / 2
Calculation: PriorBarRange = abs(high[1] - low[1])
Calculation: LiquiditySweepBull = low < PriorLowestLow AND close > PriorBarMidpoint + sweep strength * PriorBarRange
Calculation: LiquiditySweepBear = high > PriorHighestHigh AND close < PriorBarMidpoint - sweep strength * PriorBarRange
Calculation: BullPinBar = low < PriorLowestLow AND close > open AND close - open > pin ratio * (open - low)
Calculation: BearPinBar = high > PriorHighestHigh AND close < open AND open - close > pin ratio * (high - open)
Calculation: PatternPointsLong = both pattern points if LiquiditySweepBull AND BullPinBar, else single pattern points if LiquiditySweepBull OR BullPinBar, else 0
Calculation: PatternPointsShort = both pattern points if LiquiditySweepBear AND BearPinBar, else single pattern points if LiquiditySweepBear OR BearPinBar, else 0
Calculation: CumDelta = running sum of (volume if close > open, else -volume)
Calculation: BullConfluenceCount = number of true among (close > VWAP(close, T1 bars, last completed bar), HighVolume, MacdBullish, LiquiditySweepBull, CumDelta > CumDelta[1])
Calculation: BearConfluenceCount = number of true among (close < VWAP(close, T1 bars, last completed bar), HighVolume, MacdBearish, LiquiditySweepBear, CumDelta < CumDelta[1])
Calculation: TradeScoreLong = TrendPointsLong + MomentumPointsLong + VolatilityPoints + VolumePoints + PatternPointsLong
Calculation: TradeScoreShort = TrendPointsShort + MomentumPointsShort + VolatilityPoints + VolumePoints + PatternPointsShort
Calculation: EntriesToday = number of entries taken since the start of the current day
Long: BullConfluenceCount >= min confluence count AND volatility index close (T2 bars, last completed bar) < volatility pause level AND EntriesToday < daily trade limit AND TrendUp AND ADX(ADX length) > ADX chop threshold AND (ADX(ADX length) <= ADX trend threshold OR (+DI(ADX length) > -DI(ADX length) AND close > EMA(close, bias EMA length))) AND TradeScoreLong >= min long trade score
Short: BearConfluenceCount >= min confluence count AND volatility index close (T2 bars, last completed bar) < volatility pause level AND EntriesToday < daily trade limit AND NOT TrendUp AND ADX(ADX length) > ADX chop threshold AND (ADX(ADX length) <= ADX trend threshold OR (-DI(ADX length) > +DI(ADX length) AND close < EMA(close, bias EMA length))) AND TradeScoreShort >= min short trade score AND NOT (ATR(ATR length) > high-volatility multiple * SMA(ATR(ATR length), high-volatility average length))
Exit: long, close <= entry price - StopOffset[bars since entry]
Exit: long, high >= entry price + TickOffset(take-profit ticks long) * ProfitScale
Exit: long, high >= entry price + TickOffset(max profit ticks)
Exit: long, highest close since entry >= entry price + TickOffset(min trail ticks) AND highest high since entry >= entry price + TickOffset(trail ticks) AND low <= highest high since entry - TickOffset(trail offset ticks)
Exit: long, bars since entry > time stop bars
Exit: short, close >= entry price + StopOffset[bars since entry]
Exit: short, low <= entry price - TickOffset(take-profit ticks short) * ProfitScale
Exit: short, low <= entry price - TickOffset(max profit ticks)
Exit: short, lowest close since entry <= entry price - min trail ticks / point value AND lowest low since entry <= entry price - TickOffset(trail ticks) AND high >= lowest low since entry + TickOffset(trail offset ticks)
Exit: short, bars since entry > time stop bars