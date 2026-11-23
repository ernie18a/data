Calculation: PercentK = Smooth(SMA(Stochastic(stochastic source, high, low, stochastic length), K smoothing length), smoothing method, smoothing length), where Smooth returns its input unchanged when smoothing method is None
Calculation: BullRun = IF(trend source > SMA(trend source, trend length) AND PercentK >= MIN(bull range low, bull range high) AND PercentK <= MAX(bull range low, bull range high), BullRun[1] + 1, 0)
Calculation: BearRun = IF(trend source < SMA(trend source, trend length) AND PercentK >= MIN(bear range low, bear range high) AND PercentK <= MAX(bear range low, bear range high), BearRun[1] + 1, 0)
Calculation: Regime = IF(BullRun >= confirm bars, 1, IF(BearRun >= confirm bars, -1, 0))
Long: Regime = 1 AND Regime[1] != 1 AND (HTF confirmation off OR T1 shorter than chart timeframe OR Regime of T1 bars at last completed T1 bar = 1) AND (chop filter off OR ADX(ADX length) >= ADX minimum) AND ATR(ATR length) * SL multiple > minimum price tick AND close - ATR(ATR length) * SL multiple > 0
Short: Regime = -1 AND Regime[1] != -1 AND (HTF confirmation off OR T1 shorter than chart timeframe OR Regime of T1 bars at last completed T1 bar = -1) AND (chop filter off OR ADX(ADX length) >= ADX minimum) AND ATR(ATR length) * SL multiple > minimum price tick AND close - ATR(ATR length) * max(TP1 multiple, TP2 multiple, TP3 multiple) > 0
Exit: long, close < entry price - ATR(ATR length) at entry bar * SL multiple
Exit: long, high >= entry price + ATR(ATR length) at entry bar * min(TP1 multiple, TP2 multiple, TP3 multiple)
Exit: long, high >= entry price + ATR(ATR length) at entry bar * median(TP1 multiple, TP2 multiple, TP3 multiple)
Exit: long, high >= entry price + ATR(ATR length) at entry bar * max(TP1 multiple, TP2 multiple, TP3 multiple)
Exit: long, Regime = 1 AND Regime[1] != 1 AND (HTF confirmation off OR T1 shorter than chart timeframe OR Regime of T1 bars at last completed T1 bar = 1) AND (chop filter off OR ADX(ADX length) >= ADX minimum) AND ATR(ATR length) * SL multiple > minimum price tick AND close - ATR(ATR length) * SL multiple > 0
Exit: short, close > entry price + ATR(ATR length) at entry bar * SL multiple
Exit: short, low <= entry price - ATR(ATR length) at entry bar * min(TP1 multiple, TP2 multiple, TP3 multiple)
Exit: short, low <= entry price - ATR(ATR length) at entry bar * median(TP1 multiple, TP2 multiple, TP3 multiple)
Exit: short, low <= entry price - ATR(ATR length) at entry bar * max(TP1 multiple, TP2 multiple, TP3 multiple)
Exit: short, Regime = -1 AND Regime[1] != -1 AND (HTF confirmation off OR T1 shorter than chart timeframe OR Regime of T1 bars at last completed T1 bar = -1) AND (chop filter off OR ADX(ADX length) >= ADX minimum) AND ATR(ATR length) * SL multiple > minimum price tick AND close - ATR(ATR length) * max(TP1 multiple, TP2 multiple, TP3 multiple) > 0