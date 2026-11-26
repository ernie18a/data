Calculation: Atr = ATR(atr length)
Calculation: FastEma = EMA(close, fast length), where fast length < mid length < slow length
Calculation: MidEma = EMA(close, mid length)
Calculation: SlowEma = EMA(close, slow length)
Calculation: Slope = (FastEma - FastEma[slope lookback]) / Atr * 100
Calculation: Rsi = RSI(close, rsi length)
Calculation: StochPct = Stochastic(close, high, low, stoch length)
Calculation: Adx = ADX(adx length)
Calculation: VolumeAvg = SMA(volume, volume average length)
Calculation: Vwap = VWAP(typical price, volume) over chart bars, reset when a new T5 bar starts
Calculation: BodyRatio = abs(close - open) / (high - low)
Calculation: RangePos = (close - LOWEST(low, range lookback)) / (HIGHEST(high, range lookback) - LOWEST(low, range lookback))
Calculation: VecRel = volume * (high - low) / SMA(volume * (high - low), vector lookback)
Calculation: VecBull = VecRel >= vector threshold AND BodyRatio >= vector min body AND close > open
Calculation: VecBear = VecRel >= vector threshold AND BodyRatio >= vector min body AND close < open
Calculation: HighPivot = PivotHigh(high, pivot length, 1)
Calculation: LowPivot = PivotLow(low, pivot length, 1)
Calculation: SwingHigh = last defined HighPivot not yet crossed above by close
Calculation: SwingLow = last defined LowPivot not yet crossed below by close
Calculation: BreakUp = close crosses above SwingHigh
Calculation: BreakDown = close crosses below SwingLow
Calculation: TfScore(T) = sign(EMA(close, MTF fast length) - EMA(close, MTF mid length)) + sign(close - EMA(close, MTF slow length)) + [RSI(close, MTF rsi length) > MTF rsi upper] - [RSI(close, MTF rsi length) < MTF rsi lower], computed on bars of T at the last completed bar of T, for each T in T1..T5, where MTF fast length < MTF mid length < MTF slow length, MTF rsi lower < MTF rsi upper, sign(x) is 1 if x > 0, -1 if x < 0, else 0, and [x] is 1 if x holds else 0
Calculation: TfBullCount = number of T in T1..T5 with TfScore(T) >= MTF direction threshold
Calculation: TfBearCount = number of T in T1..T5 with TfScore(T) <= -MTF direction threshold
Calculation: BullScore = min(score cap, w trend order * [FastEma > MidEma] + w trend close * [close > SlowEma] + w slope * [Slope > min slope] + (Rsi < rsi oversold ? w rsi extreme : Rsi < rsi mid long ? w rsi mild : 0) + (StochPct < stoch low ? w stoch extreme : StochPct < stoch mid long ? w stoch mild : 0) + ((BreakUp AND previous structure break was bearish) ? w choch : BreakUp ? w bos : 0) + (BullishEngulfing ? w engulf : Hammer(wick multiple, small wick fraction) ? w wick pattern : ((BodyRatio > body threshold) AND close > open) ? w body : 0) + (volume > VolumeAvg * volume multiplier ? w volume : 0) + (RangePos < support fraction ? w range : 0) + (Adx > adx min ? w adx : 0) + ((abs(close - Vwap) < Atr * vwap band factor) AND close > Vwap ? w vwap : 0) + (VecBull ? w vector : 0) + w mtf * TfBullCount)
Calculation: BearScore = min(score cap, w trend order * [FastEma < MidEma] + w trend close * [close < SlowEma] + w slope * [Slope < -min slope] + (Rsi > rsi overbought ? w rsi extreme : Rsi > rsi mid short ? w rsi mild : 0) + (StochPct > stoch high ? w stoch extreme : StochPct > stoch mid short ? w stoch mild : 0) + ((BreakDown AND previous structure break was bullish) ? w choch : BreakDown ? w bos : 0) + (BearishEngulfing ? w engulf : ShootingStar(wick multiple, small wick fraction) ? w wick pattern : ((BodyRatio > body threshold) AND close < open) ? w body : 0) + (volume > VolumeAvg * volume multiplier ? w volume : 0) + (RangePos > resistance fraction ? w range : 0) + (Adx > adx min ? w adx : 0) + ((abs(close - Vwap) < Atr * vwap band factor) AND close < Vwap ? w vwap : 0) + (VecBear ? w vector : 0) + w mtf * TfBearCount)
Long: BullScore >= entry threshold AND BullScore - BearScore >= min score gap AND Adx >= adx min AND TfBullCount >= min TFs AND Slope > min slope AND position side is not long
Short: BearScore >= entry threshold AND BearScore - BullScore >= min score gap AND Adx >= adx min AND TfBearCount >= min TFs AND Slope < -min slope AND position side is not short
Long: BullScore >= round(pending fraction * entry threshold) AND BullScore < entry threshold AND BullScore - BearScore >= min score gap AND Adx >= adx min AND TfBullCount >= min TFs AND Slope > min slope AND position side is not long
Short: BearScore >= round(pending fraction * entry threshold) AND BearScore < entry threshold AND BearScore - BullScore >= min score gap AND Adx >= adx min AND TfBearCount >= min TFs AND Slope < -min slope AND position side is not short
Exit: long, low <= entry price - stop ATR multiple * Atr at entry OR high >= entry price + stop ATR multiple * target RR multiple * Atr at entry
Exit: short, high >= entry price + stop ATR multiple * Atr at entry OR low <= entry price - stop ATR multiple * target RR multiple * Atr at entry
Long: BreakUp
Long: VecBull
Long: LowPivot is not NA
Long: TfBullCount >= alert TF count
Short: BreakDown
Short: VecBear
Short: HighPivot is not NA
Short: TfBearCount >= alert TF count