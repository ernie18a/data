Calculation: Trend = sign(current close - SMA(close, average lookback)), calculated on T bars and sampled on chart bars with lookahead off (last completed T bar historically; forming T bar in realtime)
Calculation: Weighted score(trend, bullish when above, weight) = 0 if trend is unavailable; weight × trend if bullish when above; otherwise -weight × trend
Calculation: Real-yield trend = trend(real-yield close, T1)
Calculation: US dollar index trend = trend(US dollar index close, T2)
Calculation: 10-year Treasury-yield trend = trend(10-year Treasury-yield close, T2)
Calculation: 2-year Treasury-yield trend = trend(2-year Treasury-yield close, T2)
Calculation: Long-duration Treasury-bond trend = trend(long-duration Treasury-bond price, T2)
Calculation: USD/JPY trend = trend(USD/JPY close, T2)
Calculation: Silver trend = trend(silver price, T2)
Calculation: Gold-miner trend = trend(gold-miner ETF price, T2)
Calculation: Volatility-index trend = trend(volatility-index value, T2)
Calculation: High-yield-credit trend = trend(high-yield-credit ETF price, T2)
Calculation: Macro score = weighted score(real-yield trend, below-average bullish, real-yield weight) + weighted score(US dollar index trend, below-average bullish, US dollar index weight) + weighted score(10-year Treasury-yield trend, below-average bullish, 10-year Treasury-yield weight) + weighted score(2-year Treasury-yield trend, below-average bullish, 2-year Treasury-yield weight) + weighted score(long-duration Treasury-bond trend, above-average bullish, long-duration Treasury-bond weight) + weighted score(USD/JPY trend, below-average bullish, USD/JPY weight) + weighted score(silver trend, above-average bullish, silver weight) + weighted score(gold-miner trend, above-average bullish, gold-miner weight) + weighted score(volatility-index trend, above-average bullish, volatility-index weight) + weighted score(high-yield-credit trend, above-average bullish, high-yield-credit weight)
Long: real-yield trend < 0 AND real-yield weight > 0
Short: real-yield trend > 0 AND real-yield weight > 0
Long: US dollar index trend < 0 AND US dollar index weight > 0
Short: US dollar index trend > 0 AND US dollar index weight > 0
Long: 10-year Treasury-yield trend < 0 AND 10-year Treasury-yield weight > 0
Short: 10-year Treasury-yield trend > 0 AND 10-year Treasury-yield weight > 0
Long: 2-year Treasury-yield trend < 0 AND 2-year Treasury-yield weight > 0
Short: 2-year Treasury-yield trend > 0 AND 2-year Treasury-yield weight > 0
Long: long-duration Treasury-bond trend > 0 AND long-duration Treasury-bond weight > 0
Short: long-duration Treasury-bond trend < 0 AND long-duration Treasury-bond weight > 0
Long: USD/JPY trend < 0 AND USD/JPY weight > 0
Short: USD/JPY trend > 0 AND USD/JPY weight > 0
Long: silver trend > 0 AND silver weight > 0
Short: silver trend < 0 AND silver weight > 0
Long: gold-miner trend > 0 AND gold-miner weight > 0
Short: gold-miner trend < 0 AND gold-miner weight > 0
Long: volatility-index trend > 0 AND volatility-index weight > 0
Short: volatility-index trend < 0 AND volatility-index weight > 0
Long: high-yield-credit trend > 0 AND high-yield-credit weight > 0
Short: high-yield-credit trend < 0 AND high-yield-credit weight > 0
Long: macro score > 0
Short: macro score < 0
Long: Technical Rating on T3 bars, sampled on chart bars with lookahead off (last completed T3 bar historically; forming T3 bar in realtime), >= technical-rating direction threshold
Short: Technical Rating on T3 bars, sampled on chart bars with lookahead off (last completed T3 bar historically; forming T3 bar in realtime), <= -technical-rating direction threshold
Calculation: Safe-haven score = count of true conditions among volatility-index trend > 0, high-yield-credit trend < 0, gold-miner trend > 0, US dollar index trend > 0, and long-duration Treasury-bond trend > 0
Calculation: Yield-pressure score = count of true conditions among real-yield trend > 0, 10-year Treasury-yield trend > 0, 2-year Treasury-yield trend > 0, long-duration Treasury-bond trend < 0, USD/JPY trend > 0, and US dollar index trend > 0
Calculation: Dollar-pressure score = count of true conditions among US dollar index trend > 0, USD/JPY trend > 0, and real-yield trend > 0
Calculation: Inflation-hedge score = count of true conditions among silver trend > 0, gold-miner trend > 0, US dollar index trend < 0, and real-yield trend < 0
Calculation: Yield-relief score = count of true conditions among real-yield trend < 0, 10-year Treasury-yield trend < 0, 2-year Treasury-yield trend < 0, long-duration Treasury-bond trend > 0, USD/JPY trend < 0, and US dollar index trend < 0
Calculation: Maximum regime score = max(safe-haven score, yield-pressure score, dollar-pressure score, inflation-hedge score, yield-relief score)
Long: maximum regime score >= minimum regime classification score AND (safe-haven score = maximum regime score OR (safe-haven score < maximum regime score AND yield-pressure score < maximum regime score AND dollar-pressure score < maximum regime score AND (inflation-hedge score = maximum regime score OR (inflation-hedge score < maximum regime score AND yield-relief score = maximum regime score))))
Short: maximum regime score >= minimum regime classification score AND (safe-haven score < maximum regime score AND yield-pressure score = maximum regime score OR safe-haven score < maximum regime score AND yield-pressure score < maximum regime score AND dollar-pressure score = maximum regime score)
Calculation: Macro direction = sign(macro score)
Calculation: Technical direction = 1 if Technical Rating >= technical-rating direction threshold; -1 if Technical Rating <= -technical-rating direction threshold; otherwise 0
Calculation: Regime direction = 1 if regime is supportive; -1 if regime is opposing; otherwise 0
Calculation: Final direction score = macro direction × macro direction weight + technical direction + regime direction
Long: final direction score > 0
Short: final direction score < 0
Calculation: Trend-strength score = round(clamp((0 if sum of macro weights is 0; otherwise macro score × macro strength multiplier / sum of macro weights) + (0 if Technical Rating is unavailable; otherwise Technical Rating × technical strength multiplier) + regime direction × regime strength magnitude, -maximum absolute strength, maximum absolute strength))
Long: trend-strength score > 0
Short: trend-strength score < 0
Calculation: One-bar percent change(x, T4) = 100 × (close(x, T4) - close(x, T4)[1]) / close(x, T4)[1], calculated on T4 bars and sampled on chart bars with lookahead off (last completed T4 bar historically; forming T4 bar in realtime)
Long: one-bar percent change(instrument, T4) > 0
Short: one-bar percent change(instrument, T4) < 0
Long: one-bar percent change(real yield, T4) > 0
Short: one-bar percent change(real yield, T4) < 0
Long: one-bar percent change(US dollar index, T4) > 0
Short: one-bar percent change(US dollar index, T4) < 0
Long: one-bar percent change(10-year Treasury yield, T4) > 0
Short: one-bar percent change(10-year Treasury yield, T4) < 0
Long: one-bar percent change(2-year Treasury yield, T4) > 0
Short: one-bar percent change(2-year Treasury yield, T4) < 0
Long: one-bar percent change(long-duration Treasury-bond price, T4) > 0
Short: one-bar percent change(long-duration Treasury-bond price, T4) < 0
Long: one-bar percent change(USD/JPY, T4) > 0
Short: one-bar percent change(USD/JPY, T4) < 0
Long: one-bar percent change(silver, T4) > 0
Short: one-bar percent change(silver, T4) < 0
Long: one-bar percent change(gold-miner ETF price, T4) > 0
Short: one-bar percent change(gold-miner ETF price, T4) < 0
Long: one-bar percent change(volatility index, T4) > 0
Short: one-bar percent change(volatility index, T4) < 0
Long: one-bar percent change(high-yield-credit ETF price, T4) > 0
Short: one-bar percent change(high-yield-credit ETF price, T4) < 0
Calculation: Bar delta volume = 0 if high = low; otherwise volume × ((close - low) - (high - close)) / (high - low)
Calculation: Session delta = sum of bar delta volume since the session boundary
Calculation: Average session delta = arithmetic mean of up to the session-average lookback most recent completed session deltas
Long: session delta > 0
Short: session delta < 0
Long: average session delta > 0
Short: average session delta < 0
Long: bar delta volume on T5 bars, sampled on chart bars with lookahead off (last completed T5 bar historically; forming T5 bar in realtime), > 0
Short: bar delta volume on T5 bars, sampled on chart bars with lookahead off (last completed T5 bar historically; forming T5 bar in realtime), < 0
Long: SMA(bar delta volume, T5 average-delta lookback) on T5 bars, sampled on chart bars with lookahead off (last completed T5 bar historically; forming T5 bar in realtime), > 0
Short: SMA(bar delta volume, T5 average-delta lookback) on T5 bars, sampled on chart bars with lookahead off (last completed T5 bar historically; forming T5 bar in realtime), < 0
Long: bar delta volume on T6 bars, sampled on chart bars with lookahead off (last completed T6 bar historically; forming T6 bar in realtime), > 0
Short: bar delta volume on T6 bars, sampled on chart bars with lookahead off (last completed T6 bar historically; forming T6 bar in realtime), < 0
Long: SMA(bar delta volume, T6 average-delta lookback) on T6 bars, sampled on chart bars with lookahead off (last completed T6 bar historically; forming T6 bar in realtime), > 0
Short: SMA(bar delta volume, T6 average-delta lookback) on T6 bars, sampled on chart bars with lookahead off (last completed T6 bar historically; forming T6 bar in realtime), < 0
Long: bar delta volume on T7 bars, sampled on chart bars with lookahead off (last completed T7 bar historically; forming T7 bar in realtime), > 0
Short: bar delta volume on T7 bars, sampled on chart bars with lookahead off (last completed T7 bar historically; forming T7 bar in realtime), < 0
Long: SMA(bar delta volume, T7 average-delta lookback) on T7 bars, sampled on chart bars with lookahead off (last completed T7 bar historically; forming T7 bar in realtime), > 0
Short: SMA(bar delta volume, T7 average-delta lookback) on T7 bars, sampled on chart bars with lookahead off (last completed T7 bar historically; forming T7 bar in realtime), < 0
Long: bar delta volume on T8 bars, sampled on chart bars with lookahead off (last completed T8 bar historically; forming T8 bar in realtime), > 0
Short: bar delta volume on T8 bars, sampled on chart bars with lookahead off (last completed T8 bar historically; forming T8 bar in realtime), < 0
Long: SMA(bar delta volume, T8 average-delta lookback) on T8 bars, sampled on chart bars with lookahead off (last completed T8 bar historically; forming T8 bar in realtime), > 0
Short: SMA(bar delta volume, T8 average-delta lookback) on T8 bars, sampled on chart bars with lookahead off (last completed T8 bar historically; forming T8 bar in realtime), < 0