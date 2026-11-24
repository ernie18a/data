Calculation: RangeHigh = Highest(high, range lookback)[1]
Calculation: RangeLow = Lowest(low, range lookback)[1]
Calculation: RangeWidth = RangeHigh - RangeLow
Calculation: RangeFlag = (RangeWidth / RangeLow) * 100 <= maximum range width percent
Calculation: SwingHigh = Highest(high, swing lookback)[1]
Calculation: SwingLow = Lowest(low, swing lookback)[1]
Calculation: ShortestEma = EMA(close, shortest EMA lookback)
Calculation: MiddleEma = EMA(close, middle EMA lookback)
Calculation: LongestEma = EMA(close, longest EMA lookback)
Calculation: BullAlign = close > ShortestEma AND ShortestEma > MiddleEma AND MiddleEma > LongestEma
Calculation: BearAlign = close < ShortestEma AND ShortestEma < MiddleEma AND MiddleEma < LongestEma
Calculation: RangeNoTrend = RangeFlag AND NOT BullAlign AND NOT BearAlign
Calculation: AtrValue = ATR(ATR lookback)
Calculation: WideRange = RangeWidth >= AtrValue * minimum range ATR multiple
Calculation: LowerZone = RangeLow + RangeWidth * reversion zone fraction
Calculation: UpperZone = RangeHigh - RangeWidth * reversion zone fraction
Calculation: RsiValue = RSI(close, RSI lookback)
Calculation: MacdHist = MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback)
Calculation: MidBand = BollingerBasis(close, BB lookback)
Calculation: SessionVwap = VWAP(typical price, session)
Calculation: VwapLongPass = NOT VWAP filter enabled OR close > SessionVwap
Calculation: VwapShortPass = NOT VWAP filter enabled OR close < SessionVwap
Calculation: HtfEma = EMA(close, HTF EMA lookback, T1, last completed bar)
Calculation: HtfLongPass = NOT HTF filter enabled OR close > HtfEma
Calculation: HtfShortPass = NOT HTF filter enabled OR close < HtfEma
Calculation: VolumeExpansion = volume >= volume multiplier * SMA(volume, volume average lookback)
Calculation: VolumeConfirmed = volume unavailable OR VolumeExpansion
Calculation: VolumePass = NOT volume filter enabled OR VolumeConfirmed
Calculation: ObvUp = OBV(close, volume) > SMA(OBV(close, volume), OBV average lookback)
Calculation: ObvDown = OBV(close, volume) < SMA(OBV(close, volume), OBV average lookback)
Calculation: BullConfluence = count of true among (BullAlign), (bull RSI lower bound < RsiValue < bull RSI upper bound), (MacdHist > 0), (close > MidBand), (VolumeExpansion AND ObvUp), (close > open AND close > SwingHigh)
Calculation: BearConfluence = count of true among (BearAlign), (bear RSI lower bound < RsiValue < bear RSI upper bound), (MacdHist < 0), (close < MidBand), (VolumeExpansion AND ObvDown), (close < open AND close < SwingLow)
Calculation: LongRaw = (trend logic enabled AND BullAlign AND BullConfluence >= minimum confluence AND HtfLongPass AND VwapLongPass) OR (momentum logic enabled AND close > ShortestEma AND RsiValue > momentum long RSI threshold AND MacdHist > 0 AND MacdHist > MacdHist[1] AND ObvUp AND VolumePass AND HtfLongPass AND VwapLongPass) OR (breakout logic enabled AND RangeFlag AND close > RangeHigh + AtrValue * breakout ATR buffer AND close[1] <= RangeHigh[1] AND (close - low) / (high - low) >= breakout close fraction AND RsiValue > breakout RSI midline AND MacdHist > 0 AND VolumePass AND (NOT breakout volume required OR VolumeConfirmed) AND VwapLongPass) OR (reversion logic enabled AND RangeNoTrend AND WideRange AND low <= LowerZone AND close > LowerZone AND close > open AND (MIN(open, close) - low) / (high - low) >= reversion wick ratio AND RsiValue < reversion long RSI threshold AND (NOT RSI turn requirement OR RsiValue > RsiValue[1]) AND VolumePass)
Calculation: ShortRaw = (trend logic enabled AND BearAlign AND BearConfluence >= minimum confluence AND HtfShortPass AND VwapShortPass) OR (momentum logic enabled AND close < ShortestEma AND RsiValue < momentum short RSI threshold AND MacdHist < 0 AND MacdHist < MacdHist[1] AND ObvDown AND VolumePass AND HtfShortPass AND VwapShortPass) OR (breakout logic enabled AND RangeFlag AND close < RangeLow - AtrValue * breakout ATR buffer AND close[1] >= RangeLow[1] AND (close - low) / (high - low) <= 1 - breakout close fraction AND RsiValue < breakout RSI midline AND MacdHist < 0 AND VolumePass AND (NOT breakout volume required OR VolumeConfirmed) AND VwapShortPass) OR (reversion logic enabled AND RangeNoTrend AND WideRange AND high >= UpperZone AND close < UpperZone AND close < open AND (high - MAX(open, close)) / (high - low) >= reversion wick ratio AND RsiValue > reversion short RSI threshold AND (NOT RSI turn requirement OR RsiValue < RsiValue[1]) AND VolumePass)
Calculation: LongCandidate = LongRaw AND (NOT LongRaw[1] OR fresh setup only disabled) AND (no prior signal OR bars since last signal > cooldown bars) AND (position side flat OR (wait for exit disabled AND (allow opposite signal enabled OR position side long)))
Calculation: ShortCandidate = ShortRaw AND (NOT ShortRaw[1] OR fresh setup only disabled) AND (no prior signal OR bars since last signal > cooldown bars) AND (position side flat OR (wait for exit disabled AND (allow opposite signal enabled OR position side short)))
Calculation: LongStopLevel = IF stop method = ATR THEN entry price - AtrValue at entry bar * stop ATR multiple ELSE IF stop method = fixed percent THEN entry price * (1 - fixed stop percent / 100) ELSE IF SwingLow at entry bar - AtrValue at entry bar * structure ATR buffer < entry price THEN SwingLow at entry bar - AtrValue at entry bar * structure ATR buffer ELSE entry price - AtrValue at entry bar * stop ATR multiple
Calculation: LongTargetLevel = IF target method = ATR THEN entry price + AtrValue at entry bar * target ATR multiple ELSE IF target method = fixed percent THEN entry price * (1 + fixed target percent / 100) ELSE entry price + (entry price - LongStopLevel) * risk-reward ratio
Calculation: ShortStopLevel = IF stop method = ATR THEN entry price + AtrValue at entry bar * stop ATR multiple ELSE IF stop method = fixed percent THEN entry price * (1 + fixed stop percent / 100) ELSE IF SwingHigh at entry bar + AtrValue at entry bar * structure ATR buffer > entry price THEN SwingHigh at entry bar + AtrValue at entry bar * structure ATR buffer ELSE entry price + AtrValue at entry bar * stop ATR multiple
Calculation: ShortTargetLevel = IF target method = ATR THEN entry price - AtrValue at entry bar * target ATR multiple ELSE IF target method = fixed percent THEN entry price * (1 - fixed target percent / 100) ELSE entry price - (ShortStopLevel - entry price) * risk-reward ratio
Long: LongCandidate AND (NOT ShortCandidate OR BullConfluence > BearConfluence)
Short: ShortCandidate AND (NOT LongCandidate OR BearConfluence > BullConfluence)
Exit: long, low <= LongStopLevel
Exit: long, high >= LongTargetLevel
Exit: short, high >= ShortStopLevel
Exit: short, low <= ShortTargetLevel