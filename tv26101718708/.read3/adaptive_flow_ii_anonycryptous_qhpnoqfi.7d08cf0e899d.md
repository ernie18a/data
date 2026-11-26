Calculation: Flow = KAMA(Price, adaptive length, fast constant, slow constant) if |KAMA(Price, adaptive length, fast constant, slow constant) - Flow[1]| > ATR(ATR length) * noise threshold, otherwise Flow[1]
Calculation: Stop = Flow - ATR(ATR length) * ATR multiplier if Dir = 1 AND Dir[1] = -1; Flow + ATR(ATR length) * ATR multiplier if Dir = -1 AND Dir[1] = 1; max(Stop[1], Flow - ATR(ATR length) * ATR multiplier) if Dir = 1; min(Stop[1], Flow + ATR(ATR length) * ATR multiplier) otherwise
Calculation: Level = if the stop-mode parameter selects ratchet trailing: Stop[1]; if it selects lookback trailing: highest(Flow, stop lookback) - ATR(ATR length) * ATR multiplier when Dir[1] = 1, lowest(Flow, stop lookback) + ATR(ATR length) * ATR multiplier when Dir[1] = -1; if it selects pivot trailing: Flow at the bar of the most recent PivotLow(Flow, pivot left, pivot right) - ATR(ATR length) * pivot buffer when Dir[1] = 1, Flow at the bar of the most recent PivotHigh(Flow, pivot left, pivot right) + ATR(ATR length) * pivot buffer when Dir[1] = -1
Calculation: Dir = -1 if Dir[1] = 1 AND Flow < Level; 1 if Dir[1] = -1 AND Flow > Level; otherwise Dir[1]
Calculation: SwingHigh = high at the bar of the most recent PivotHigh(high, pivot left, pivot right)
Calculation: SwingLow = low at the bar of the most recent PivotLow(low, pivot left, pivot right)
Calculation: Structure = 1 if close > SwingHigh[1] AND Structure[1] != 1 AND BearBOSes[1] >= BOS required; -1 if close < SwingLow[1] AND Structure[1] != -1 AND BullBOSes[1] >= BOS required; otherwise Structure[1]
Calculation: BullBOSes = 0 if Structure != Structure[1]; BullBOSes[1] + 1 if close > SwingHigh[1] AND Structure[1] = 1; otherwise BullBOSes[1]
Calculation: BearBOSes = 0 if Structure != Structure[1]; BearBOSes[1] + 1 if close < SwingLow[1] AND Structure[1] = -1; otherwise BearBOSes[1]
Calculation: BarsSinceLong = bars elapsed since the most recent earlier bar on which the trend-flip-up Long rule held
Calculation: BarsSinceShort = bars elapsed since the most recent earlier bar on which the trend-flip-down Short rule held
Long: Dir = 1 AND Dir[1] = -1 AND Price > EMA(Price, EMA length, T1, last completed bar) AND ADX(ADX length) >= ADX threshold AND bar time inside session window AND BarsSinceLong >= cooldown
Long: close > SwingHigh[1] AND Structure[1] = 1
Long: close > SwingHigh[1] AND Structure[1] != 1 AND BearBOSes[1] >= BOS required
Long: close > SwingHigh
Short: Dir = -1 AND Dir[1] = 1 AND Price < EMA(Price, EMA length, T1, last completed bar) AND ADX(ADX length) >= ADX threshold AND bar time inside session window AND BarsSinceShort >= cooldown
Short: close < SwingLow[1] AND Structure[1] = -1
Short: close < SwingLow[1] AND Structure[1] != -1 AND BullBOSes[1] >= BOS required
Short: close < SwingLow
Exit: long, Dir = -1 AND Dir[1] = 1
Exit: short, Dir = 1 AND Dir[1] = -1