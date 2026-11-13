Calculation: Sigmoid(f) = 1/(1+exp(-f))
Calculation: AdaptiveEMA(x, feed, n) = recursive EMA seeded with the first x value: y = y_prev + a*(x - y_prev), where a = clamp((2/(n+1))*(0.5+Sigmoid(feed)), small positive floor, 1)
Calculation: Baseline = AdaptiveEMA(close, feed = change over k bars of RSI(close, m), n = baseline length)
Calculation: RawVol = median absolute deviation of close over the lookback = median(|close_i - median(close over lookback)|)
Calculation: VolFeed = change over k bars of (RawVol / EMA(RawVol, volatility length))
Calculation: Vol = AdaptiveEMA(RawVol, VolFeed, volatility length)
Calculation: ret = ln(close/close_prev); bull = max(ret,0)^2; bear = max(-ret,0)^2; total = bull+bear; bullVar, bearVar, totalVar = AdaptiveEMA(bull, VolFeed, baseline length), AdaptiveEMA(bear, VolFeed, baseline length), AdaptiveEMA(total, VolFeed, baseline length); bullRatio = totalVar>0 ? sqrt(max(2*bullVar/totalVar,0)) : 1; bearRatio = totalVar>0 ? sqrt(max(2*bearVar/totalVar,0)) : 1; upperMult = 1 + g*(bullRatio-1); lowerMult = 1 + g*(bearRatio-1), with g a constant amplification factor greater than 1
Calculation: avgMult = SMA of mean(upperMult, lowerMult) over a lookback longer than the other lengths (use the available bars while history is shorter); upperMultAdj, lowerMultAdj = upperMult, lowerMult each clamped to [avgMult - s, avgMult + s], with s a constant spread
Calculation: UpperBand = Baseline + max(Vol*upperMultAdj, tiny positive floor)*M; LowerBand = Baseline - max(Vol*lowerMultAdj, tiny positive floor)*M, with M a constant volatility multiple
Long: close > UpperBand (state is held until the opposite condition triggers)
Short: close < LowerBand (state is held until the opposite condition triggers)