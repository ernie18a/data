Calculation: LastPivotHigh = most recent confirmed pivot high of high(pivot left length, pivot right length)
Calculation: LastPivotLow = most recent confirmed pivot low of low(pivot left length, pivot right length)
Calculation: FibLevel = LastPivotHigh - fib ratio * (LastPivotHigh - LastPivotLow) if LastPivotHigh > LastPivotLow, else LastPivotLow + fib ratio * abs(LastPivotHigh - LastPivotLow)
Calculation: CVD = Delta if session reset enabled AND a new T2 bar begins at this chart bar, else CVD[1] + Delta, where Delta = volume if close > open, -volume if close < open, else 0
Calculation: POC = center price of the bin with the largest summed volume, where the range from the lowest low to the highest high of the last VP lookback length bars (including this bar) is split into VP bin count equal bins, each of those bars adds its volume to the bin containing (high + low + close)/3 clamped to the outermost bins, and ties go to the lowest bin
Calculation: SuperTrendDir = direction of SuperTrend(SuperTrend source, SuperTrend ATR length, SuperTrend multiplier), up or down
Calculation: VSAflag = volume / SMA(volume, VSA length) > RVOL threshold AND abs(high - low) > SMA(abs(high - low), VSA length)
Calculation: Bias = 1 if close(T1, last completed bar) > EMA(close, HTF EMA length, T1, last completed bar) AND (VSAflag = false OR close > open); -1 if close(T1, last completed bar) < EMA(close, HTF EMA length, T1, last completed bar) AND (VSAflag = false OR close <= open); else 0
Calculation: VolHigh = volume > SMA(volume, volume average length)
Calculation: BodyStrong = abs(close - open) > ATR(filter ATR length) * body multiple
Calculation: BullFVG = low > high[2]
Calculation: BearFVG = high < low[2]
Calculation: BullCHoCH = close crosses above LastPivotHigh
Calculation: BearCHoCH = close crosses below LastPivotLow
Calculation: BullConfluence = number of true among BullFVG = true, BullCHoCH = true, Bias = 1, SuperTrendDir = up, close > FibLevel, CVD > 0, close > POC
Calculation: BearConfluence = number of true among BearFVG = true, BearCHoCH = true, Bias = -1, SuperTrendDir = down, close < FibLevel, CVD < 0, close < POC
Long: BullFVG = true
Long: BullCHoCH = true
Long: SuperTrendDir = up
Short: BearFVG = true
Short: BearCHoCH = true
Short: SuperTrendDir = down
Long: BullConfluence >= confluence sensitivity AND (use volume filter = false OR VolHigh = true) AND (use body filter = false OR BodyStrong = true)
Short: BearConfluence >= confluence sensitivity AND (use volume filter = false OR VolHigh = true) AND (use body filter = false OR BodyStrong = true)