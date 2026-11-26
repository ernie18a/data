Calculation: lastPivotHigh = most recent confirmed Pivot High(high, swing length)
Calculation: priorPivotHigh = second-most-recent confirmed Pivot High(high, swing length)
Calculation: lastPivotLow = most recent confirmed Pivot Low(low, swing length)
Calculation: priorPivotLow = second-most-recent confirmed Pivot Low(low, swing length)
Calculation: bullStructure = lastPivotHigh > priorPivotHigh AND lastPivotLow > priorPivotLow
Calculation: bearStructure = lastPivotHigh < priorPivotHigh AND lastPivotLow < priorPivotLow
Calculation: inDemand = close within any confirmed demand band, where each newly confirmed Pivot Low p increments the count of the earliest band containing p or else opens band [p * (1 - buffer), p * (1 + buffer)] with count 1, and a band is confirmed when its count >= min rejections
Calculation: inSupply = close within any confirmed supply band, where each newly confirmed Pivot High p increments the count of the earliest band containing p or else opens band [p * (1 - buffer), p * (1 + buffer)] with count 1, and a band is confirmed when its count >= min rejections
Calculation: pendingUp = close crosses above priorPivotHigh OR (pendingUp[1] AND NOT supportRetest[1])
Calculation: supportRetest = pendingUp AND low <= priorPivotHigh * (1 + buffer) AND close > priorPivotHigh
Calculation: pendingDown = close crosses below priorPivotLow OR (pendingDown[1] AND NOT resistanceRetest[1])
Calculation: resistanceRetest = pendingDown AND high >= priorPivotLow * (1 - buffer) AND close < priorPivotLow
Calculation: bullScore = number of true among: bullStructure; inDemand; close crosses above priorPivotHigh; supportRetest; close > VWAP(hlc3) reset each new T1 period; EMA(close, shorter EMA length) > EMA(close, longer EMA length); RSI(close, RSI length) > RSI midline
Calculation: bearScore = number of true among: bearStructure; inSupply; close crosses below priorPivotLow; resistanceRetest; close < VWAP(hlc3) reset each new T1 period; EMA(close, shorter EMA length) < EMA(close, longer EMA length); RSI(close, RSI length) < RSI midline
Calculation: stopDistance = ATR(ATR length) on the entry bar * (scalp stop multiplier if chart timeframe is T2, T3, or T4, otherwise stop multiplier)
Calculation: cooldownBars = swing length * (scalp cooldown multiplier if chart timeframe is T2, T3, or T4, otherwise cooldown multiplier)
Calculation: lockout = (consecutive stop-out exits since the last target exit or since the last bar whose date differs from the previous bar's date) >= max losses
Long: bullScore >= min score AND (no prior score long entry OR bullScore < min score - release offset at some bar since the last score long entry) AND (no prior score short entry OR bearScore < min score - release offset at some bar since the last score short entry) AND NOT lockout AND (no prior score long entry OR bars since the last score long entry > cooldownBars)
Long: bullStructure
Long: inDemand AND NOT inDemand[1]
Short: bearScore >= min score AND (no prior score short entry OR bearScore < min score - release offset at some bar since the last score short entry) AND (no prior score long entry OR bullScore < min score - release offset at some bar since the last score long entry) AND NOT lockout AND (no prior score short entry OR bars since the last score short entry > cooldownBars)
Short: bearStructure
Short: inSupply AND NOT inSupply[1]
Exit: long, low <= entry price - stopDistance
Exit: long, high >= entry price + target multiple * stopDistance AND low > entry price - stopDistance
Exit: short, high >= entry price + stopDistance
Exit: short, low <= entry price - target multiple * stopDistance AND high < entry price + stopDistance