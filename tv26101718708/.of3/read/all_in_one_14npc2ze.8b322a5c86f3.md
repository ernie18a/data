Calculation: SwingHigh(n) = last non-NA PivotHigh(high, n, n)
Calculation: SwingLow(n) = last non-NA PivotLow(low, n, n)
Calculation: PrevSwingHigh(n) = non-NA PivotHigh(high, n, n) before the last one
Calculation: PrevSwingLow(n) = non-NA PivotLow(low, n, n) before the last one
Calculation: StructTrend(TF) = on bars of TF: -1 if close crosses below SwingLow(StructLen), else 1 if close crosses above SwingHigh(StructLen), else StructTrend(TF)[1]
Calculation: UpBreak = close crosses above SwingHigh(StructLen) AND StructTrend[1] != 1
Calculation: DownBreak = close crosses below SwingLow(StructLen) AND StructTrend[1] != -1
Calculation: Downtrend = close < EMA(close, RefEMALen)
Calculation: Uptrend = close > EMA(close, RefEMALen)
Calculation: LowReclaim = low < EMA(close, BaseEMALen) - ATR(ATRLen) * ExtMult AND close > EMA(close, BaseEMALen) - ATR(ATRLen) * BandMult
Calculation: HighReclaim = high > EMA(close, BaseEMALen) + ATR(ATRLen) * ExtMult AND close < EMA(close, BaseEMALen) + ATR(ATRLen) * BandMult
Calculation: LowSweep = low < SwingLow(RevLen) AND close > SwingLow(RevLen)
Calculation: HighSweep = high > SwingHigh(RevLen) AND close < SwingHigh(RevLen)
Calculation: LowSweepValid = LowSweep AND Downtrend
Calculation: HighSweepValid = HighSweep AND Uptrend
Calculation: LowDivergence = SwingLow(RevLen) < PrevSwingLow(RevLen) AND RSI(close, RSILen) at the bar of SwingLow(RevLen) > RSI(close, RSILen) at the bar of PrevSwingLow(RevLen)
Calculation: HighDivergence = SwingHigh(RevLen) > PrevSwingHigh(RevLen) AND RSI(close, RSILen) at the bar of SwingHigh(RevLen) < RSI(close, RSILen) at the bar of PrevSwingHigh(RevLen)
Calculation: LowWick = min(open, close) - low > WickBodyMult * max(abs(close - open), tick size) AND min(open, close) - low > ATR(ATRLen) * WickATRFrac
Calculation: HighWick = high - max(open, close) > WickBodyMult * max(abs(close - open), tick size) AND high - max(open, close) > ATR(ATRLen) * WickATRFrac
Calculation: ClimaxVolume = volume / SMA(volume, VolAvgLen) >= ClimaxFactor
Calculation: LowFailedBreak = low < low[1] AND close > low[1] AND close > open
Calculation: HighFailedBreak = high > high[1] AND close < high[1] AND close < open
Calculation: LowMicro = close > high[1] OR LowFailedBreak
Calculation: HighMicro = close < low[1] OR HighFailedBreak
Calculation: LowCore = LowSweep OR LowReclaim OR LowFailedBreak
Calculation: HighCore = HighSweep OR HighReclaim OR HighFailedBreak
Calculation: LowFade = RSI(close, RSILen) < FadeLow AND RSI(close, RSILen) > RSI(close, RSILen)[1]
Calculation: HighFade = RSI(close, RSILen) > FadeHigh AND RSI(close, RSILen) < RSI(close, RSILen)[1]
Calculation: LowWprHook = WilliamsR(WPRLen)[1] <= WPROS AND WilliamsR(WPRLen) > WilliamsR(WPRLen)[1]
Calculation: HighWprHook = WilliamsR(WPRLen)[1] >= WPROB AND WilliamsR(WPRLen) < WilliamsR(WPRLen)[1]
Calculation: NearLow = low <= SwingLow(RevLen) + ATR(ProxLen) * ProxMult
Calculation: NearHigh = high >= SwingHigh(RevLen) - ATR(ProxLen) * ProxMult
Calculation: UpDownRatio = Sum(volume where close > close[1], UDWin) / Sum(volume where close < close[1], UDWin), or 1 if the denominator is 0
Calculation: HistVolBar = chart timeframe is T3, T4 or T5 AND (volume >= Highest(volume, all bars so far) OR volume == Highest(volume, BarsPerYear))
Calculation: MtfUpOk = count of StructTrend(Tk, last completed bar) >= 0 over k = 1 to 3 is at least MtfMinCount
Calculation: MtfDownOk = count of StructTrend(Tk, last completed bar) <= 0 over k = 1 to 3 is at least MtfMinCount
Calculation: LowRevScore = (LowSweepValid ? PtsSweepValid : LowSweep ? PtsSweep : 0) + (LowDivergence ? PtsDiv : 0) + (LowWick ? PtsWick : 0) + (ClimaxVolume ? PtsClimax : 0) + (LowReclaim ? PtsInside : 0) + (LowMicro ? PtsMicro : 0) + (LowWprHook ? PtsWpr : 0) + (MtfUpOk ? PtsMtf : 0) + (NearLow ? PtsNear : 0) + (LowFade ? PtsFade : 0) + (UpDownRatio < UDWeak ? PtsUD : 0) + (HistVolBar AND Downtrend ? PtsHist : 0)
Calculation: HighRevScore = (HighSweepValid ? PtsSweepValid : HighSweep ? PtsSweep : 0) + (HighDivergence ? PtsDiv : 0) + (HighWick ? PtsWick : 0) + (ClimaxVolume ? PtsClimax : 0) + (HighReclaim ? PtsInside : 0) + (HighMicro ? PtsMicro : 0) + (HighWprHook ? PtsWpr : 0) + (MtfDownOk ? PtsMtf : 0) + (NearHigh ? PtsNear : 0) + (HighFade ? PtsFade : 0) + (UpDownRatio > UDStrong ? PtsUD : 0) + (HistVolBar AND Uptrend ? PtsHist : 0)
Calculation: LowPivotNew = PivotLow(low, RevLen, RevLen) is not NA on this bar
Calculation: HighPivotNew = PivotHigh(high, RevLen, RevLen) is not NA on this bar
Calculation: LowRevLock = LowRevSignal OR (LowRevLock[1] AND NOT LowPivotNew)
Calculation: HighRevLock = HighRevSignal OR (HighRevLock[1] AND NOT HighPivotNew)
Calculation: StackUp = close > EMA(close, ShortEMALen) AND EMA(close, ShortEMALen) > EMA(close, MidEMALen) AND EMA(close, MidEMALen) > EMA(close, LongEMALen) AND ADX(ADXLen) > ADXLevel
Calculation: StackDown = close < EMA(close, ShortEMALen) AND EMA(close, ShortEMALen) < EMA(close, MidEMALen) AND EMA(close, MidEMALen) < EMA(close, LongEMALen) AND ADX(ADXLen) > ADXLevel
Calculation: LowRevSignal = (NOT ADXFilterOn OR NOT StackDown OR LowSweepValid OR LowReclaim) AND LowCore AND LowRevScore >= SignalMin AND (NOT LowRevLock[1] OR LowPivotNew) AND NOT (LowRevSignal in previous RevCool bars) AND (NOT (DownBreak in last BreakCool bars including current bar) OR LowSweepValid) AND (NOT ExtReqOn OR Downtrend OR LowReclaim)
Calculation: HighRevSignal = (NOT ADXFilterOn OR NOT StackUp OR HighSweepValid OR HighReclaim) AND HighCore AND HighRevScore >= SignalMin AND (NOT HighRevLock[1] OR HighPivotNew) AND NOT (HighRevSignal in previous RevCool bars) AND (NOT (UpBreak in last BreakCool bars including current bar) OR HighSweepValid) AND (NOT ExtReqOn OR Uptrend OR HighReclaim)
Long: UpBreak
Short: DownBreak
Long: close crosses above SwingHigh(InternalLen)
Short: close crosses below SwingLow(InternalLen)
Long: volume > SMA(volume, VolAvgLen) * VolFactor AND close >= open
Short: volume > SMA(volume, VolAvgLen) * VolFactor AND close < open
Long: low > high[2]
Short: high < low[2]
Long: RSI(close, RSILen) > RSIMid
Short: RSI(close, RSILen) <= RSIMid
Long: close < average(SwingHigh(StructLen), SwingLow(StructLen))
Short: close > average(SwingHigh(StructLen), SwingLow(StructLen))
Long: LowRevSignal
Long: LowRevSignal AND LowRevScore >= StrongMin
Short: HighRevSignal
Short: HighRevSignal AND HighRevScore >= StrongMin
Long: NOT LowRevSignal AND LowCore AND LowRevScore >= SetupMin
Short: NOT HighRevSignal AND HighCore AND HighRevScore >= SetupMin