Calculation: trend = MA(close, trendLen, trendType)
Calculation: crossed = close crosses above trend OR close crosses below trend
Calculation: pullbackBars = count of bars since and including the most recent crossed bar where (close > trend AND close < open) OR (close < trend AND close > open)
Calculation: setupActive = crossed OR (setupActive[1] AND NOT (Long OR Short)[1])
Calculation: setupHigh = highest high from the most recent crossed bar through the current bar, counting only bars up to and including the first bar where pullbackConfirmed is true
Calculation: setupLow = lowest low from the most recent crossed bar through the current bar, counting only bars up to and including the first bar where pullbackConfirmed is true
Calculation: pullbackConfirmed = setupActive AND ((pullbackConfirmed[1] AND NOT crossed) OR (pullbackBars >= pullbackN AND abs(close - trend) / (setupHigh - setupLow if nonzero, else 1) >= pullbackDepthMin AND (NOT filtersOn OR abs(close - trend) / trend < maDistMax)))
Calculation: t1Ema = EMA(close, t1EmaLen, T1, last completed bar)
Calculation: slopeDeg = atan((t1Ema / t1Ema[slopeLen] - 1) * 100 / slopeLen) * 180 / pi
Calculation: relVolume = volume / SMA(volume, volLen)
Calculation: filtersOn = forcedOn OR (NOT forcedOff AND (NOT adaptive OR ATR(atrLen) / close * 100 < atrMax))
Long: pullbackConfirmed AND close > setupHigh AND (NOT filtersOn OR relVolume >= relVolMin) AND (NOT t1TrendOn OR close > t1Ema) AND (NOT t1DistOn OR abs(close - t1Ema) / t1Ema < t1DistMax) AND (NOT slopeOn OR slopeDeg >= slopeMinDeg)
Short: pullbackConfirmed AND close < setupLow AND (NOT filtersOn OR relVolume >= relVolMin) AND (NOT t1TrendOn OR close < t1Ema) AND (NOT t1DistOn OR abs(close - t1Ema) / t1Ema < t1DistMax) AND (NOT slopeOn OR slopeDeg <= -slopeMinDeg)
Long: close > t1Ema
Short: close <= t1Ema
Long: slopeDeg >= slopeMinDeg
Short: slopeDeg <= -slopeMinDeg
Exit: long, low <= setupLow at entry OR high >= entry price + (entry price - setupLow at entry) * rrMult
Exit: short, high >= setupHigh at entry OR low <= entry price - (setupHigh at entry - entry price) * rrMult