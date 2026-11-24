Calculation: UpWeight = sum over i from 1 to history length of (weight base + (history length - i) / history length) * [close[i] > close[i+1]]
Calculation: DownWeight = sum over i from 1 to history length of (weight base + (history length - i) / history length) * [close[i] < close[i+1]]
Calculation: UpShare = UpWeight / (UpWeight + DownWeight)
Calculation: DownShare = DownWeight / (UpWeight + DownWeight)
Calculation: TrendSign = sign(UpShare - DownShare)
Calculation: MemoryValue = clamp(memory decay * MemoryValue[1] + TrendSign * (memory base weight + memory gain weight * abs(UpShare - DownShare)), -memory cap, memory cap)
Calculation: MemorySign = 1 if MemoryValue > memory threshold, -1 if MemoryValue < -memory threshold, else 0
Calculation: PreferredSign = TrendSign if TrendSign != 0, else MemorySign
Calculation: ConfHit = [max(UpShare, DownShare) >= confidence threshold]
Calculation: MomHit = [abs(UpShare - DownShare) >= momentum threshold]
Calculation: HtfTrendUp = (close > EMA(close, trend EMA length) AND EMA(close, trend EMA length) > EMA(close, trend EMA length)[1]), on T2 bars at the completed bar before the last completed T2 bar
Calculation: HtfTrendDown = (close < EMA(close, trend EMA length) AND EMA(close, trend EMA length) < EMA(close, trend EMA length)[1]), on T2 bars at the completed bar before the last completed T2 bar
Calculation: HtfRsi = RSI(close, RSI length), on T1 bars at the completed bar before the last completed T1 bar
Calculation: VolumePass = [volume filter disabled OR volume > min relative volume * SMA(volume, volume filter length)]
Calculation: AtrPass = [ATR filter disabled OR ATR(ATR length) >= min ATR ratio * SMA(ATR(ATR length), ATR SMA length)]
Calculation: MacdUp = [MACD line > MACD signal line], with MACD(close, MACD fast length, MACD slow length, MACD signal length)
Calculation: MacdDown = [MACD line < MACD signal line], with MACD(close, MACD fast length, MACD slow length, MACD signal length)
Calculation: AdxStrong = [ADX(ADX DI length, ADX smoothing length) > ADX threshold]
Calculation: SniperBull = 100 * ([close > VWAP(hlc3)] + [RSI(close, RSI length) > RSI midline] + MacdUp + [EMA(close, fast sniper EMA length) > EMA(close, slow sniper EMA length)] + [AdxStrong AND close > EMA(close, fast sniper EMA length)] + [volume > SMA(volume, sniper volume length) AND close > open] + [HtfRsi > RSI midline]) / 7
Calculation: SniperBear = 100 * ([close < VWAP(hlc3)] + [RSI(close, RSI length) < RSI midline] + MacdDown + [EMA(close, fast sniper EMA length) < EMA(close, slow sniper EMA length)] + [AdxStrong AND close < EMA(close, fast sniper EMA length)] + [volume > SMA(volume, sniper volume length) AND close < open] + [HtfRsi < RSI midline]) / 7
Calculation: InSession = [time filter disabled OR (session start hour <= session end hour AND hour(datetime) >= session start hour AND hour(datetime) < session end hour) OR (session start hour > session end hour AND (hour(datetime) >= session start hour OR hour(datetime) < session end hour))]
Calculation: IntervalOK = [no prior entry OR time since last entry >= signal interval]
Calculation: LongPoints = preferred weight * [PreferredSign == 1] + [TrendSign == 1] + [MemorySign == 1] + ConfHit + MomHit + [EMA trend filter disabled OR (close > EMA(close, trend EMA length) AND EMA(close, trend EMA length) > EMA(close, trend EMA length)[1])] + [HTF trend filter disabled OR HtfTrendUp] + VolumePass + AtrPass + [candle filter disabled OR (close > open AND abs(close - open) / (high - low) >= min body ratio)] + bias direction weight * [SniperBull > SniperBear] + [SniperBull - SniperBear >= strong bias difference] + [close > VWAP(hlc3)] + MacdUp + AdxStrong + [HtfRsi > RSI midline]
Calculation: ShortPoints = preferred weight * [PreferredSign == -1] + [TrendSign == -1] + [MemorySign == -1] + ConfHit + MomHit + [EMA trend filter disabled OR (close < EMA(close, trend EMA length) AND EMA(close, trend EMA length) < EMA(close, trend EMA length)[1])] + [HTF trend filter disabled OR HtfTrendDown] + VolumePass + AtrPass + [candle filter disabled OR (close < open AND abs(close - open) / (high - low) >= min body ratio)] + bias direction weight * [SniperBear > SniperBull] + [SniperBear - SniperBull >= strong bias difference] + [close < VWAP(hlc3)] + MacdDown + AdxStrong + [HtfRsi < RSI midline]
Calculation: LongCand = (IntervalOK AND InSession AND (no prior entry OR last entry was not long OR close >= last entry price + min move ATR multiple * ATR(ATR length)) AND (sniper bias filter disabled OR (SniperBull > SniperBear AND SniperBull >= sniper min percent) OR SniperBull - SniperBear >= strong bias difference) AND LongPoints >= signal score minimum AND LongPoints - ShortPoints >= signal edge minimum) OR (sniper cross trigger enabled AND EMA(close, fast sniper EMA length) crosses above EMA(close, slow sniper EMA length) AND SniperBull > SniperBear AND SniperBull >= sniper min percent AND close > VWAP(hlc3) AND MacdUp AND HtfRsi > RSI midline)
Calculation: ShortCand = (IntervalOK AND InSession AND (no prior entry OR last entry was not short OR close <= last entry price - min move ATR multiple * ATR(ATR length)) AND (sniper bias filter disabled OR (SniperBear > SniperBull AND SniperBear >= sniper min percent) OR SniperBear - SniperBull >= strong bias difference) AND ShortPoints >= signal score minimum AND ShortPoints - LongPoints >= signal edge minimum) OR (sniper cross trigger enabled AND EMA(close, fast sniper EMA length) crosses below EMA(close, slow sniper EMA length) AND SniperBear > SniperBull AND SniperBear >= sniper min percent AND close < VWAP(hlc3) AND MacdDown AND HtfRsi < RSI midline)
Calculation: LongSig = LongCand AND (NOT ShortCand OR SniperBull >= SniperBear)
Calculation: ShortSig = ShortCand AND (NOT LongCand OR SniperBear > SniperBull)
Long: LongSig AND position is flat AND long entries enabled
Short: ShortSig AND position is flat AND short entries enabled
Calculation: Risk = ATR(ATR length) on the first in-position bar * stop multiple
Calculation: LongTrail = max over bars since the first bar where highest high since entry - entry price >= trailing activation * ATR(ATR length), of (highest high since entry - trailing multiple * ATR(ATR length))
Calculation: ShortTrail = min over bars since the first bar where entry price - lowest low since entry >= trailing activation * ATR(ATR length), of (lowest low since entry + trailing multiple * ATR(ATR length))
Exit: long, opposite-signal exit enabled AND ShortSig AND bars since entry >= min hold bars
Exit: short, opposite-signal exit enabled AND LongSig AND bars since entry >= min hold bars
Exit: long, early exit enabled AND bars since entry >= min hold bars AND (TP1 gate disabled OR highest high since entry[1] >= entry price + TP step * Risk) AND (close crosses below EMA(close, exit EMA length) OR (RSI exit enabled AND RSI(close, RSI length)[1] > RSI overbought level AND RSI(close, RSI length) < RSI overbought level) OR (close < open AND close[1] > open[1] AND close < open[1] AND open > close[1]))
Exit: short, early exit enabled AND bars since entry >= min hold bars AND (TP1 gate disabled OR lowest low since entry[1] <= entry price - TP step * Risk) AND (close crosses above EMA(close, exit EMA length) OR (RSI exit enabled AND RSI(close, RSI length)[1] < RSI oversold level AND RSI(close, RSI length) > RSI oversold level) OR (close > open AND close[1] < open[1] AND close > open[1] AND open < close[1]))
Exit: long, low <= entry price - Risk OR (trailing enabled AND low <= LongTrail[1])
Exit: short, high >= entry price + Risk OR (trailing enabled AND high >= ShortTrail[1])
Exit: long, TP enabled AND high >= entry price + 1 * TP step * Risk
Exit: long, TP enabled AND high >= entry price + 2 * TP step * Risk
Exit: long, TP enabled AND high >= entry price + 3 * TP step * Risk
Exit: long, TP enabled AND high >= entry price + 4 * TP step * Risk
Exit: long, TP enabled AND high >= entry price + 5 * TP step * Risk
Exit: short, TP enabled AND low <= entry price - 1 * TP step * Risk
Exit: short, TP enabled AND low <= entry price - 2 * TP step * Risk
Exit: short, TP enabled AND low <= entry price - 3 * TP step * Risk
Exit: short, TP enabled AND low <= entry price - 4 * TP step * Risk
Exit: short, TP enabled AND low <= entry price - 5 * TP step * Risk