Calculation: Stage(x, n) = (1 + gain) * EMA(x, n) - gain * EMA(EMA(x, n), n)
Calculation: LagFree(x, n) = Stage(Stage(Stage(x, n), n), n)
Calculation: SmoothPlusDI = LagFree(+DI(high, low, close, DI length), smoothing length)
Calculation: SmoothMinusDI = LagFree(-DI(high, low, close, DI length), smoothing length)
Calculation: AdxValue = ADX(high, low, close, ADX DI length, ADX smoothing length)
Calculation: BreakoutHigh = Highest(high, highest-high lookback)[1]
Calculation: BreakoutLow = Lowest(low, lowest-low lookback)[1]
Calculation: TrailDistance = ATR(high, low, close, trailing ATR period) * trailing ATR multiplier
Calculation: LongTrailStop = if TrendState = +1 then max(close - TrailDistance, LongTrailStop[1]) else 0
Calculation: ShortTrailStop = if TrendState = -1 then min(close + TrailDistance, ShortTrailStop[1]) else +infinity
Calculation: FixStop = if TrendState = +1 then C - A * fixed ATR multiplier; if TrendState = -1 then C + A * fixed ATR multiplier; otherwise undefined; C = close and A = ATR(high, low, close, fixed ATR period) on the bar where TrendState last changed from 0 to nonzero
Calculation: TrailStop = if TrendState = +1 then LongTrailStop; if TrendState = -1 then ShortTrailStop; otherwise undefined
Calculation: TrendState = if TrendState[1] = 0 then (+1 if close crosses above BreakoutHigh; -1 if close crosses below BreakoutLow; otherwise 0); if TrendState[1] = +1 then (0 if close crosses below BreakoutLow OR low <= max(FixStop[1], LongTrailStop[1]); otherwise +1); if TrendState[1] = -1 then (0 if close crosses above BreakoutHigh OR high >= min(FixStop[1], ShortTrailStop[1]); otherwise -1)
Long: TrailStop < BreakoutLow AND close > close[1] AND SmoothPlusDI > SmoothMinusDI AND AdxValue > ADX threshold
Short: TrailStop > BreakoutHigh AND close < close[1] AND SmoothPlusDI < SmoothMinusDI AND AdxValue > ADX threshold
Exit: long, high >= entry price * (1 + take-profit 1 percent / 100)
Exit: long, high >= entry price * (1 + take-profit 2 percent / 100)
Exit: long, high >= entry price * (1 + take-profit 3 percent / 100)
Exit: long, high >= entry price * (1 + take-profit 4 percent / 100)
Exit: short, low <= entry price * (1 - take-profit 1 percent / 100)
Exit: short, low <= entry price * (1 - take-profit 2 percent / 100)
Exit: short, low <= entry price * (1 - take-profit 3 percent / 100)
Exit: short, low <= entry price * (1 - take-profit 4 percent / 100)
Exit: long, close < entry price * (1 - stop-loss percent / 100)
Exit: short, close > entry price * (1 + stop-loss percent / 100)
Exit: long, low <= max(FixStop[1], LongTrailStop[1])
Exit: short, high >= min(FixStop[1], ShortTrailStop[1])