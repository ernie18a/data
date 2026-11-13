Calculation: norm(x; lo, hi) = 100 * (clamp(x, lo, hi) - lo) / (hi - lo), with lo < hi fixed constants per component. All bars are on the chart timeframe, using the current (just-completed) bar.
Calculation: atrScore = norm(ATR(short lookback) / ATR(long lookback), ...); the ratio is 0 if the long ATR is 0.
Calculation: bodyScore = norm(|close - open| / (high - low), ...); the ratio is 0 if high = low.
Calculation: volScore = norm(volume / EMA(volume), ...); the ratio is 0 if the EMA is 0.
Calculation: speedScore = norm(breakDist / ATR(long lookback), ...), where prevHigh = highest high of the N bars before the current bar and prevLow = lowest low of the N bars before the current bar. breakDist = close - prevHigh if close > prevHigh; = prevLow - close if close < prevLow; otherwise 0.
Calculation: dir = +1 if close > EMA(close), -1 if close < EMA(close), else 0.
Calculation: pullbackScore = 50 if dir = 0. Otherwise it is 100 - norm(depth, ...), where swingHigh/swingLow are the highest high/lowest low over M bars including the current bar, and range = swingHigh - swingLow. If range = 0, depth = 1. If dir = +1, depth = (swingHigh - close) / range. If dir = -1, depth = (close - swingLow) / range.
Calculation: score = weighted sum of atrScore, bodyScore, volScore, speedScore, pullbackScore, with weights summing to 1. atrScore has the largest weight, pullbackScore the smallest, and bodyScore, volScore and speedScore share an equal middle weight.
Long: score >= strongLevel AND dir = +1 (the first bar of a consecutive run where either this or the Short condition holds is the marked onset)
Short: score >= strongLevel AND dir = -1 (the first bar of a consecutive run where either this or the Long condition holds is the marked onset)