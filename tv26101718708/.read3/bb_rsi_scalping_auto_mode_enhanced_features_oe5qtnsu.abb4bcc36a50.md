Calculation: BBMid = SMA(close, BB lookback)
Calculation: BBUpper = BBMid + BB multiplier * STDEV(close, BB lookback)
Calculation: BBLower = BBMid - BB multiplier * STDEV(close, BB lookback)
Calculation: BandWidth = BBUpper - BBLower
Calculation: BandsExpanding = BandWidth > SMA(BandWidth, auto band-width lookback)
Calculation: RSIVal = RSI(close, RSI lookback)
Calculation: DynRSIOS = Lowest(RSIVal, dynamic RSI lookback) + dynamic RSI buffer
Calculation: DynRSIOB = Highest(RSIVal, dynamic RSI lookback) - dynamic RSI buffer
Calculation: MacdLine = EMA(close, shorter MACD lookback) - EMA(close, longer MACD lookback)
Calculation: MacdSignal = EMA(MacdLine, MACD signal lookback)
Calculation: MacdHist = MacdLine - MacdSignal
Calculation: BullHistTurn = MacdHist > MacdHist[1] AND MacdHist[1] < MacdHist[2]
Calculation: BearHistTurn = MacdHist < MacdHist[1] AND MacdHist[1] > MacdHist[2]
Calculation: Recent(X) = X OR X[1] OR ... OR X[confirmation window]
Calculation: Hit(X) = X on some bar since entry, including current bar
Calculation: PriorHit(X) = X on some bar since entry, excluding current bar
Calculation: VolStrong = volume > SMA(volume, volume lookback) * volume multiplier
Calculation: VolOK = VolStrong AND (volume-increase requirement disabled OR volume > volume[1])
Calculation: StopATR = ATR(stop ATR lookback)
Calculation: EntryATR = StopATR at entry bar
Calculation: VolatilityExpanding = StopATR > SMA(StopATR, auto ATR lookback)
Calculation: AutoVolStrong = volume > SMA(volume, volume lookback) * auto volume multiplier
Calculation: AutoAggressive = BandsExpanding AND VolatilityExpanding AND AutoVolStrong
Calculation: AutoConservative = NOT BandsExpanding AND NOT AutoVolStrong
Calculation: EffectiveMode = entry mode if entry mode is fixed; else aggressive if AutoAggressive; else conservative if AutoConservative; else balanced
Calculation: NearLower = low <= BBLower + BandWidth * near band percent / 100
Calculation: NearUpper = high >= BBUpper - BandWidth * near band percent / 100
Calculation: GreenCandle = close > open
Calculation: RedCandle = close < open
Calculation: AggLong = NearLower AND RSIVal <= DynRSIOS + near RSI buffer
Calculation: AggShort = NearUpper AND RSIVal >= DynRSIOB - near RSI buffer
Calculation: BalLong = AggLong AND GreenCandle
Calculation: BalShort = AggShort AND RedCandle
Calculation: ConsLong = low < BBLower AND close > BBLower AND close > close[1] AND RSIVal <= DynRSIOS AND Recent(BullHistTurn) AND Recent(VolOK)
Calculation: ConsShort = high > BBUpper AND close < BBUpper AND close < close[1] AND RSIVal >= DynRSIOB AND Recent(BearHistTurn) AND Recent(VolOK)
Calculation: BullDiv = pivot low of low (pivot lookback) confirmed on current bar AND low[pivot lookback] < low at previous pivot low AND RSIVal[pivot lookback] > RSIVal at previous pivot low AND the two pivots are at most max divergence bars apart
Calculation: BearDiv = pivot high of high (pivot lookback) confirmed on current bar AND high[pivot lookback] > high at previous pivot high AND RSIVal[pivot lookback] < RSIVal at previous pivot high AND the two pivots are at most max divergence bars apart
Calculation: LongDiv = BullDiv AND low[pivot lookback] < BBLower[pivot lookback] AND RSIVal[pivot lookback] <= DynRSIOS[pivot lookback] AND Recent(BullHistTurn) AND Recent(VolOK)
Calculation: ShortDiv = BearDiv AND high[pivot lookback] > BBUpper[pivot lookback] AND RSIVal[pivot lookback] >= DynRSIOB[pivot lookback] AND Recent(BearHistTurn) AND Recent(VolOK)
Calculation: ReversalLong = (EffectiveMode is conservative AND (ConsLong OR LongDiv)) OR (EffectiveMode is balanced AND BalLong) OR (EffectiveMode is aggressive AND AggLong)
Calculation: ReversalShort = (EffectiveMode is conservative AND (ConsShort OR ShortDiv)) OR (EffectiveMode is balanced AND BalShort) OR (EffectiveMode is aggressive AND AggShort)
Calculation: ContLongScore = number of true among (low <= BBMid), (close > BBMid), GreenCandle, (RSIVal > 50), (MacdHist > MacdHist[1]), (MacdLine >= MacdSignal), Recent(VolOK)
Calculation: ContShortScore = number of true among (high >= BBMid), (close < BBMid), RedCandle, (RSIVal < 50), (MacdHist < MacdHist[1]), (MacdLine <= MacdSignal), Recent(VolOK)
Calculation: MidlineLong = midline continuation enabled AND ContLongScore = 7
Calculation: MidlineShort = midline continuation enabled AND ContShortScore = 7
Calculation: InitialLongStop = Lowest(low, initial invalidation lookback) - tick size * invalidation tick buffer, evaluated at entry bar
Calculation: InitialShortStop = Highest(high, initial invalidation lookback) + tick size * invalidation tick buffer, evaluated at entry bar
Calculation: DynLongLevel = max over bars from entry through current of (Lowest(low, dynamic exit lookback) - tick size * invalidation tick buffer), if dynamic exit ratchet enabled; otherwise that value at entry bar
Calculation: DynShortLevel = min over bars from entry through current of (Highest(high, dynamic exit lookback) + tick size * invalidation tick buffer), if dynamic exit ratchet enabled; otherwise that value at entry bar
Calculation: TrailLongStop = max over bars from trailing activation through current of (high - StopATR * trailing stop multiplier), where trailing activation is the first bar since entry with high >= entry price + StopATR * trailing start multiplier; undefined before activation
Calculation: TrailShortStop = min over bars from trailing activation through current of (low + StopATR * trailing stop multiplier), where trailing activation is the first bar since entry with low <= entry price - StopATR * trailing start multiplier; undefined before activation
Calculation: LongTP1 = entry price + EntryATR * TP1 multiplier
Calculation: LongTP2 = entry price + EntryATR * TP2 multiplier
Calculation: LongTP3 = entry price + EntryATR * TP3 multiplier
Calculation: ShortTP1 = entry price - EntryATR * TP1 multiplier
Calculation: ShortTP2 = entry price - EntryATR * TP2 multiplier
Calculation: ShortTP3 = entry price - EntryATR * TP3 multiplier
Calculation: MomentumLongExit = (histogram inflection exit enabled AND BearHistTurn) OR (MACD cross exit enabled AND MacdLine crosses below MacdSignal) OR (RSI 50 exit enabled AND RSIVal crosses below 50)
Calculation: MomentumShortExit = (histogram inflection exit enabled AND BullHistTurn) OR (MACD cross exit enabled AND MacdLine crosses above MacdSignal) OR (RSI 50 exit enabled AND RSIVal crosses above 50)
Calculation: LongFullExit = (entry was not MidlineLong AND ((reversal exit mode is R1 AND MomentumLongExit) OR (reversal exit mode is R2 AND RedCandle) OR (reversal exit mode is R3 AND RedCandle AND MacdHist < MacdHist[1]))) OR (entry was MidlineLong AND ((continuation exit mode is C1 AND MomentumLongExit) OR (continuation exit mode is C2 AND close < BBMid AND MacdHist < MacdHist[1]) OR (continuation exit mode is C3 AND MacdLine crosses below MacdSignal))) OR low <= InitialLongStop OR low <= DynLongLevel OR (trailing stop enabled AND low <= TrailLongStop) OR (break-even enabled AND Hit(high >= entry price + StopATR * break-even multiplier) AND low <= entry price) OR (take-profit enabled AND (high >= LongTP3 OR (high >= LongTP2 AND NOT PriorHit(high >= LongTP2) AND PriorHit(high >= LongTP1))))
Calculation: LongPartialTp = take-profit enabled AND NOT LongFullExit AND high >= LongTP1 AND NOT PriorHit(high >= LongTP1)
Calculation: LongExitNow = LongFullExit OR (max holding enabled AND bar time >= entry time + max holding duration)
Calculation: ShortFullExit = (entry was not MidlineShort AND ((reversal exit mode is R1 AND MomentumShortExit) OR (reversal exit mode is R2 AND GreenCandle) OR (reversal exit mode is R3 AND GreenCandle AND MacdHist > MacdHist[1]))) OR (entry was MidlineShort AND ((continuation exit mode is C1 AND MomentumShortExit) OR (continuation exit mode is C2 AND close > BBMid AND MacdHist > MacdHist[1]) OR (continuation exit mode is C3 AND MacdLine crosses above MacdSignal))) OR high >= InitialShortStop OR high >= DynShortLevel OR (trailing stop enabled AND high >= TrailShortStop) OR (break-even enabled AND Hit(low <= entry price - StopATR * break-even multiplier) AND high >= entry price) OR (take-profit enabled AND (low <= ShortTP3 OR (low <= ShortTP2 AND NOT PriorHit(low <= ShortTP2) AND PriorHit(low <= ShortTP1))))
Calculation: ShortPartialTp = take-profit enabled AND NOT ShortFullExit AND low <= ShortTP1 AND NOT PriorHit(low <= ShortTP1)
Calculation: ShortExitNow = ShortFullExit OR (max holding enabled AND bar time >= entry time + max holding duration)
Long: position side is flat AND (session filter disabled OR bar time in trading session) AND (ReversalLong OR MidlineLong)
Short: position side is flat AND (session filter disabled OR bar time in trading session) AND (ReversalShort OR MidlineShort)
Long: position side is flat AND heads-up marking enabled AND AggLong AND no long heads-up marking on previous (heads-up cooldown - 1) bars
Short: position side is flat AND heads-up marking enabled AND AggShort AND no short heads-up marking on previous (heads-up cooldown - 1) bars
Long: position side is flat AND continuation warnings enabled AND midline continuation enabled AND NOT MidlineLong AND ContLongScore >= warning score threshold AND no long continuation warning on previous (continuation warning cooldown - 1) bars
Short: position side is flat AND continuation warnings enabled AND midline continuation enabled AND NOT MidlineShort AND ContShortScore >= warning score threshold AND no short continuation warning on previous (continuation warning cooldown - 1) bars
Exit: long, LongExitNow
Exit: long, LongPartialTp
Exit: long, exit-soon marking enabled AND MacdHist < MacdHist[1] AND NOT LongExitNow AND NOT LongPartialTp
Exit: short, ShortExitNow
Exit: short, ShortPartialTp
Exit: short, exit-soon marking enabled AND MacdHist > MacdHist[1] AND NOT ShortExitNow AND NOT ShortPartialTp