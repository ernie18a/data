Calculation: NewsDist(X) = MIN(|t - X|, minutesPerDay - |t - X|), where t = UTC minute of day of bar time
Calculation: NewsWindowActive = BlockNews AND (NewsDist(News1) <= NewsWin OR NewsDist(News2) <= NewsWin OR NewsDist(News3) <= NewsWin)
Calculation: SessionAllowed = NOT SessionFilter OR bar time within SesA OR bar time within SesB
Calculation: HTFUp = close > EMA(close, Lhtf) on T1 bars, both read one T1 bar before the last completed T1 bar
Calculation: HTFDown = close < EMA(close, Lhtf) on T1 bars, both read one T1 bar before the last completed T1 bar
Calculation: DollarUp = dollar index close > EMA(close, Ld) on T2 bars, both read one T2 bar before the last completed T2 bar
Calculation: DollarDown = dollar index close < EMA(close, Ld) on T2 bars, both read one T2 bar before the last completed T2 bar
Calculation: DollarUnknown = dollar index close or EMA(close, Ld) on T2 bars, read one T2 bar before the last completed T2 bar, is not available
Calculation: FibRange = highest(high, Lfib) - lowest(low, Lfib)
Calculation: FibZoneUp = close >= highest(high, Lfib) - Kdeep * FibRange - Bfib * ATR(La) AND close <= highest(high, Lfib) - Kshallow * FibRange + Bfib * ATR(La)
Calculation: FibZoneDown = close >= lowest(low, Lfib) + Kshallow * FibRange - Bfib * ATR(La) AND close <= lowest(low, Lfib) + Kdeep * FibRange + Bfib * ATR(La)
Calculation: UpSweep = low < lowest(low, Lliq)[1] AND close > lowest(low, Lliq)[1]
Calculation: DownSweep = high > highest(high, Lliq)[1] AND close < highest(high, Lliq)[1]
Calculation: UpMomentum = close > EMA(close, Lfast) AND close > VWAP((high + low + close) / 3) AND RSI(close, Lrsi) > Rmid AND MACD line(close, Mfast, Mslow) > MACD signal(close, Mfast, Mslow, Msig) AND ADX(Ddi, Sadx) > Xadx
Calculation: DownMomentum = close < EMA(close, Lfast) AND close < VWAP((high + low + close) / 3) AND RSI(close, Lrsi) < Rmid AND MACD line(close, Mfast, Mslow) < MACD signal(close, Mfast, Mslow, Msig) AND ADX(Ddi, Sadx) > Xadx
Calculation: UpScore = IF(HTFUp, Wh, 0) + IF(UpSweep OR NOT RequireLiq, Wl, 0) + IF(FibZoneUp OR NOT RequireFib, Wf, 0) + IF(DollarDown OR DollarUnknown OR NOT DXYOn, Wd, 0) + IF(EMA(close, Lfast) > EMA(close, Lmid) AND EMA(close, Lmid) > EMA(close, Lslow) AND close > EMA(close, Ltrend), Ws, 0) + IF(UpMomentum, Wm, 0) + IF(SessionAllowed, Wn, 0)
Calculation: DownScore = IF(HTFDown, Wh, 0) + IF(DownSweep OR NOT RequireLiq, Wl, 0) + IF(FibZoneDown OR NOT RequireFib, Wf, 0) + IF(DollarUp OR DollarUnknown OR NOT DXYOn, Wd, 0) + IF(EMA(close, Lfast) < EMA(close, Lmid) AND EMA(close, Lmid) < EMA(close, Lslow) AND close < EMA(close, Ltrend), Ws, 0) + IF(DownMomentum, Wm, 0) + IF(SessionAllowed, Wn, 0)
Calculation: RequiredScore = MAX(MinScore, ModeFloor)
Calculation: Dist(M, P) = IF(ATRTargets, ATR(La) at entry bar * M, P)
Calculation: LongStop = IF(UseSwingSL AND lowest(low, Lliq)[1] at entry bar - Sbuf < entry price, lowest(low, Lliq)[1] at entry bar - Sbuf, entry price - Dist(SLatr, SLpts))
Calculation: ShortStop = IF(UseSwingSL AND highest(high, Lliq)[1] at entry bar + Sbuf > entry price, highest(high, Lliq)[1] at entry bar + Sbuf, entry price + Dist(SLatr, SLpts))
Calculation: BestHigh = MAX(entry price, high of each bar after entry bar through current bar)
Calculation: BestLow = MIN(entry price, low of each bar after entry bar through current bar)
Long: position flat AND NOT NewsWindowActive AND SessionAllowed AND (NOT DXYStrict OR DollarDown OR DollarUnknown) AND (NOT StrictHTF OR HTFUp) AND (NOT RequireLiq OR UpSweep) AND (NOT RequireFib OR FibZoneUp) AND (NOT AvoidChase OR |close - EMA(close, Lfast)| <= ATR(La) * Cmax) AND (NOT AvoidPD OR high(T3, last completed bar) not available OR close < high(T3, last completed bar) - PDbuf OR close > high(T3, last completed bar) + PDbuf) AND UpScore >= RequiredScore AND UpScore > DownScore AND (UpSweep OR (close crosses above EMA(close, Lfast) AND close > EMA(close, Lmid)) OR (close > highest(high, Lbrk)[1] AND UpMomentum))
Short: position flat AND NOT NewsWindowActive AND SessionAllowed AND (NOT DXYStrict OR DollarUp OR DollarUnknown) AND (NOT StrictHTF OR HTFDown) AND (NOT RequireLiq OR DownSweep) AND (NOT RequireFib OR FibZoneDown) AND (NOT AvoidChase OR |close - EMA(close, Lfast)| <= ATR(La) * Cmax) AND (NOT AvoidPD OR low(T3, last completed bar) not available OR close < low(T3, last completed bar) - PDbuf OR close > low(T3, last completed bar) + PDbuf) AND DownScore >= RequiredScore AND DownScore > UpScore AND (DownSweep OR (close crosses below EMA(close, Lfast) AND close < EMA(close, Lmid)) OR (close < lowest(low, Lbrk)[1] AND DownMomentum))
Long: UpSweep
Short: DownSweep
Exit: long, high >= entry price + Dist(TP3atr, TP3pts) OR low <= LongStop OR (BestHigh[1] >= entry price + Dist(TP1atr, TP1pts) AND ((CloseAfterTP1 AND close <= BestHigh - Ppull) OR close < EMA(close, Lfast) OR RSI(close, Lrsi) < Rmid OR MACD line(close, Mfast, Mslow) < MACD signal(close, Mfast, Mslow, Msig)))
Exit: short, low <= entry price - Dist(TP3atr, TP3pts) OR high >= ShortStop OR (BestLow[1] <= entry price - Dist(TP1atr, TP1pts) AND ((CloseAfterTP1 AND close >= BestLow + Ppull) OR close > EMA(close, Lfast) OR RSI(close, Lrsi) > Rmid OR MACD line(close, Mfast, Mslow) > MACD signal(close, Mfast, Mslow, Msig)))