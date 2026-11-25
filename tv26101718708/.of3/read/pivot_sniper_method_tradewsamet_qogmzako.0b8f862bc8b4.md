Calculation: LowPivot = PivotLow(low, low pivot left lookback, low pivot right lookback)
Calculation: HighPivot = PivotHigh(high, high pivot left lookback, high pivot right lookback)
Calculation: ATR = ATR(high, low, close, ATR lookback)
Calculation: TrendEMA = EMA(close, strength trend lookback)
Calculation: BodyRatio = if high = low then 0 else abs(close - open) / (high - low)
Calculation: VolumeScore = if SMA(volume, strength volume lookback) > 0 then min(volume / SMA(volume, strength volume lookback) / volume full-points ratio, 1) * component points else neutral volume points
Calculation: LongPivotDistance = min(max((close - LowPivot) / ATR, 0), distance cap) / distance cap * component points
Calculation: ShortPivotDistance = min(max((HighPivot - close) / ATR, 0), distance cap) / distance cap * component points
Calculation: LongWick = if high[n] = low[n] then 0 else (min(open[n], close[n]) - low[n]) / (high[n] - low[n]) * component points, where n is low pivot right lookback
Calculation: ShortWick = if high[n] = low[n] then 0 else (high[n] - max(open[n], close[n])) / (high[n] - low[n]) * component points, where n is high pivot right lookback
Calculation: LongCandle = min(BodyRatio * body weight + (if close > open then direction bonus else 0), component points)
Calculation: ShortCandle = min(BodyRatio * body weight + (if close < open then direction bonus else 0), component points)
Calculation: LongTrend = (if close > TrendEMA then trend points else 0) + (if TrendEMA > TrendEMA[1] then trend points else 0)
Calculation: ShortTrend = (if close < TrendEMA then trend points else 0) + (if TrendEMA < TrendEMA[1] then trend points else 0)
Calculation: LongStrength = round(min(LongPivotDistance + LongWick + LongCandle + VolumeScore + LongTrend, 100))
Calculation: ShortStrength = round(min(ShortPivotDistance + ShortWick + ShortCandle + VolumeScore + ShortTrend, 100))
Calculation: InSession = bar datetime is within session window A or session window B, each evaluated in its own time zone
Calculation: CooldownReady = no earlier bar had LongSignal or ShortSignal true OR bars since the most recent such bar > cooldown bars
Calculation: LongSignal = LowPivot is not NA AND HighPivot is NA AND trend bias permits long AND InSession AND LongStrength >= minimum strength AND CooldownReady
Calculation: ShortSignal = HighPivot is not NA AND LowPivot is NA AND trend bias permits short AND InSession AND ShortStrength >= minimum strength AND CooldownReady
Calculation: LongEntry = LongSignal AND ATR is not NA
Calculation: ShortEntry = ShortSignal AND ATR is not NA
Long: LongEntry
Short: ShortEntry
Calculation: LongInitialStop = if requested stop < entry price - minimum price increment then requested stop else entry price - ATR at entry bar * ATR stop multiple, where requested stop = entry price - ATR at entry bar * ATR stop multiple if stop mode is M1, LowPivot at entry bar if stop mode is M2, LowPivot at entry bar - ATR at entry bar * pivot ATR buffer if stop mode is M3, low at entry bar otherwise
Calculation: ShortInitialStop = if requested stop > entry price + minimum price increment then requested stop else entry price + ATR at entry bar * ATR stop multiple, where requested stop = entry price + ATR at entry bar * ATR stop multiple if stop mode is M1, HighPivot at entry bar if stop mode is M2, HighPivot at entry bar + ATR at entry bar * pivot ATR buffer if stop mode is M3, high at entry bar otherwise
Calculation: LongRisk = entry price - LongInitialStop
Calculation: ShortRisk = ShortInitialStop - entry price
Calculation: LongStop = if break-even enabled AND the highest high over bars after the entry bar and before the current bar >= entry price + LongRisk * TP[k] R multiple then entry price + break-even offset else LongInitialStop, where k is break-even trigger target
Calculation: ShortStop = if break-even enabled AND the lowest low over bars after the entry bar and before the current bar <= entry price - ShortRisk * TP[k] R multiple then entry price - break-even offset else ShortInitialStop, where k is break-even trigger target
Exit: long, low <= LongStop
Exit: long, high >= entry price + LongRisk * TP3 R multiple
Exit: long, LongEntry
Exit: short, high >= ShortStop
Exit: short, low <= entry price - ShortRisk * TP3 R multiple
Exit: short, ShortEntry