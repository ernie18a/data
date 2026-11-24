Calculation: RelVol = volume / SMA(volume, volume length)
Calculation: VolBurst = RelVol > volume surge level AND volume > volume[1] * volume growth factor
Calculation: BullVolume = RelVol < volume compress level OR (VolBurst AND close > open AND LOWEST(RelVol, volume dip window)[1] < volume compress level)
Calculation: BearVolume = RelVol < volume compress level OR (VolBurst AND close < open AND LOWEST(RelVol, volume dip window)[1] < volume compress level)
Calculation: BodyFrac = ABS(close - open) / (high - low)
Calculation: ClosePos = (close - low) / (high - low)
Calculation: BullBar = BodyFrac > body ratio threshold AND close > open AND ClosePos > upper close-position level AND RelVol > 1
Calculation: BearBar = BodyFrac > body ratio threshold AND close < open AND ClosePos < lower close-position level AND RelVol > 1
Calculation: Velocity = (close - close[velocity lookback]) / ATR(atr length)
Calculation: AccelBull = Velocity > 0 AND Velocity > Velocity[1] AND Velocity[1] > Velocity[2]
Calculation: AccelBear = Velocity < 0 AND Velocity < Velocity[1] AND Velocity[1] < Velocity[2]
Calculation: EntropyRatio = STDEV(ABS(LN(close / close[1])), entropy length) / SMA(ABS(LN(close / close[1])), entropy length)
Calculation: EntropyPct = (EntropyRatio - LOWEST(EntropyRatio, normalization lookback)) / (HIGHEST(EntropyRatio, normalization lookback) - LOWEST(EntropyRatio, normalization lookback))
Calculation: LastSwingHigh = most recent non-NA PIVOTHIGH(high, swing length, swing length)
Calculation: PriorSwingHigh = second most recent non-NA PIVOTHIGH(high, swing length, swing length)
Calculation: LastSwingLow = most recent non-NA PIVOTLOW(low, swing length, swing length)
Calculation: PriorSwingLow = second most recent non-NA PIVOTLOW(low, swing length, swing length)
Calculation: HHHL = LastSwingHigh > PriorSwingHigh AND LastSwingLow > PriorSwingLow
Calculation: BullBreak = close crosses above LastSwingHigh
Calculation: BearBreak = close crosses below LastSwingLow
Calculation: StructTrend = IF(BullBreak, 1, IF(BearBreak, -1, StructTrend[1]))
Calculation: BullCHoCH = BullBreak AND StructTrend[1] == -1
Calculation: RangeCenter = (HIGHEST(high, range length) + LOWEST(low, range length)) / 2
Calculation: BullStack = IF(close > EMA(close, fastest lookback), 1, 0) + IF(EMA(close, fastest lookback) > EMA(close, second lookback), 1, 0) + IF(EMA(close, second lookback) > EMA(close, third lookback), 1, 0) + IF(EMA(close, third lookback) > EMA(close, slowest lookback), 1, 0), with fastest < second < third < slowest lookback
Calculation: BearStack = IF(close < EMA(close, fastest lookback), 1, 0) + IF(EMA(close, fastest lookback) < EMA(close, second lookback), 1, 0) + IF(EMA(close, second lookback) < EMA(close, third lookback), 1, 0) + IF(EMA(close, third lookback) < EMA(close, slowest lookback), 1, 0)
Calculation: BullLock = BullStack >= phase stack minimum AND close > EMA(close, second lookback)
Calculation: BearLock = BearStack >= phase stack minimum AND close < EMA(close, second lookback)
Calculation: BullOBLow = low[i] for the smallest i in [2, OB lookback] where close[i] < open[i] AND close[i-1] - open[i-1] >= OB impulse multiplier * ATR(atr length) AND RelVol[i-1] >= 1
Calculation: BullOBHigh = high[i] for the same i
Calculation: BullOBValid = BullOBLow is defined AND close > BullOBLow
Calculation: RiskATR = (close - BullOBLow) / ATR(atr length) + OB stop buffer
Calculation: LongPoints = IF(EntropyPct < entropy compression level, 1, 0) + IF(BullLock, 1, 0) + IF(BullVolume, 1, 0) + IF(BullBar, 1, 0) + IF(AccelBull, 1, 0) + IF(LOWEST(low, sweep shorter window) < LOWEST(low, sweep longer window)[1] AND close > LOWEST(low, sweep longer window)[1] AND close > open, 1, 0) + IF(EMA(close, HTF shorter lookback, T1, last completed bar) > EMA(close, HTF longer lookback, T1, last completed bar), 1, 0) + IF(BullCHoCH, CHoCH weight, 0) + IF(low > high[2] AND close > open AND BullOBValid AND high[2] >= BullOBLow AND high[2] <= BullOBHigh, 1, 0)
Calculation: LongThreshold = minimum score - IF(BullCHoCH AND NOT HHHL, 1, 0) + IF(CHOP(chop length) > soft chop level, 1, 0)
Calculation: ExitPoints = IF(EntropyPct > 1 - entropy compression level, 1, 0) + IF(BearLock, 1, 0) + IF(BearVolume, 1, 0) + IF(BearBar, 1, 0) + IF(AccelBear, 1, 0)
Calculation: TP1Level = entry price + TP1 multiple * (entry price - (BullOBLow - OB stop buffer * ATR(atr length))), with BullOBLow and ATR(atr length) taken on the entry bar
Long: LongPoints >= LongThreshold AND LongPoints[1] < LongThreshold AND CHOP(chop length) <= hard chop level AND (StructTrend == 1 OR BullCHoCH) AND close < RangeCenter AND BullOBValid AND RiskATR >= minimum risk AND RiskATR <= maximum risk AND RSI(close, rsi length) < rsi overbought level AND bars since the last long entry >= cooldown bars AND position is flat
Long: BullBreak
Short: BearBreak
Exit: long, ExitPoints >= exit score threshold OR (close > RangeCenter AND BearBar)
Exit: long, bars since entry >= time stop bars AND high < TP1Level on every bar since entry