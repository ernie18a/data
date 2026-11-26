Calculation: price source = if smoothing is enabled then EMA(close, smoothing period) else close
Calculation: trend midpoint = LinReg(price source, anchor lookback, offset 0)
Calculation: volatility rank = PercentRank(EMA(STDEV(close, volatility lookback, T1 bars), volatility smoothing period, T1 bars), rank lookback, T1 bars), taken on chart bars from the T1 bar available with lookahead off (the T1 bar still forming in realtime); use the fallback parameter when unavailable
Calculation: volatility adjustment = 1 + normalized volatility rank × volatility scaling parameter
Calculation: extension z-score = if STDEV(price source, extension lookback) > 0 then (price source − EMA(price source, extension lookback)) / STDEV(price source, extension lookback) else 0
Calculation: upper width = upper base multiplier × (1 − (1 / (1 + EXP(−extension z-score))) × upper compression parameter) × ATR(anchor lookback) × volatility adjustment
Calculation: lower width = lower base multiplier × (1 − (1 / (1 + EXP(extension z-score))) × lower compression parameter) × ATR(anchor lookback) × volatility adjustment
Calculation: raw upper boundary = upper anchor weight × Highest(price source, anchor lookback) + upper trend weight × trend midpoint − upper width
Calculation: raw lower boundary = lower anchor weight × Lowest(price source, anchor lookback) + lower trend weight × trend midpoint + lower width
Calculation: upper band = MAX(raw upper boundary, raw lower boundary)
Calculation: lower band = MIN(raw upper boundary, raw lower boundary)
Calculation: centerline = EMA((upper band + lower band) / 2, centerline smoothing period)
Calculation: long setup = (if the selected entry method is delayed centerline continuation: BarsSince(crossover(price source, centerline)) ≤ signal-age parameter AND price source > centerline AND trend midpoint > its previous chart-bar value; else if it is direct centerline crossing: crossover(price source, centerline); otherwise: crossover(price source, lower band)) AND (bar-close confirmation is disabled OR the chart bar is confirmed)
Calculation: short setup = (if the selected entry method is delayed centerline continuation: BarsSince(crossunder(price source, centerline)) ≤ signal-age parameter AND price source < centerline AND trend midpoint < its previous chart-bar value; else if it is direct centerline crossing: crossunder(price source, centerline); otherwise: crossunder(price source, upper band)) AND (bar-close confirmation is disabled OR the chart bar is confirmed)
Calculation: bullish state = true on a long setup, else false on a short setup, else retain the previous value; initially false
Long: long setup AND previous-bar bullish state is false
Short: short setup AND previous-bar bullish state is true