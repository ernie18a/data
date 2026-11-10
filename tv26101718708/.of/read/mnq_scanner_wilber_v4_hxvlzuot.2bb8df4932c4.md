Calculation: Higher-timeframe values = for each of two higher timeframes, use the last completed bar on historical chart bars and the still-forming bar on realtime chart bars; shifted values use the bar preceding that bar. The trend timeframe is higher than the pullback timeframe.
Calculation: VWAP = cumulative chart-bar typical price, (high + low + close) / 3, weighted by volume and reset each trading day.
Calculation: Long pullback = shifted pullback-timeframe low <= its EMA AND shifted close > its EMA AND unshifted close > its EMA AND unshifted close > shifted close.
Calculation: Short pullback = shifted pullback-timeframe high >= its EMA AND shifted close < its EMA AND unshifted close < its EMA AND unshifted close < shifted close.
Calculation: Long momentum = previous chart-bar range > 0 AND close > open AND absolute body / range >= minimum body fraction AND absolute body >= minimum body size AND close >= low + range * minimum upper-close fraction AND close > chart-timeframe short-term EMA AND close > VWAP; all values are from the previous chart bar.
Calculation: Short momentum = previous chart-bar range > 0 AND close < open AND absolute body / range >= minimum body fraction AND absolute body >= minimum body size AND close <= high - range * minimum lower-close fraction AND close < chart-timeframe short-term EMA AND close < VWAP; all values are from the previous chart bar. The upper-close and lower-close fractions are equal.
Calculation: VWAP conflict = (chart close > higher trend-timeframe long-term EMA AND chart close < VWAP) OR (chart close < higher trend-timeframe long-term EMA AND chart close > VWAP).
Calculation: Session window = chart-bar opening time in America/New_York lies within any configured intraday window, including its start and excluding its end.
Long: chart close > higher trend-timeframe long-term EMA.
Short: chart close <= higher trend-timeframe long-term EMA.
Long: VWAP conflict = false AND chart close > VWAP.
Short: VWAP conflict = false AND chart close <= VWAP.
Long: session window = true AND VWAP conflict = false AND chart close > higher trend-timeframe long-term EMA AND at least two of (chart close > VWAP, long pullback = true, long momentum = true) are true.
Short: session window = true AND VWAP conflict = false AND chart close < higher trend-timeframe long-term EMA AND at least two of (chart close < VWAP, short pullback = true, short momentum = true) are true.