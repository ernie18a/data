Calculation: Bar delta = (+1 if close ≥ open, else −1) × volume × ratio, where ratio = |close − open| / (high − low) if high > low, else neutral ratio parameter
Calculation: CVD = running sum of Bar delta, restarted at each session start
Calculation: Sigma = sqrt(max(0, VWAP(tp²) − VWAP²)), where tp = (high + low + close) / 3 and VWAP(x) = session volume-weighted average of x
Calculation: Upper band = VWAP + band multiplier × Sigma
Calculation: Lower band = VWAP − band multiplier × Sigma
Long: Lowest(low, FA lookback) < Lower band − narrow FA proximity AND Lower band − narrow FA proximity < close < Lower band + wide FA proximity AND Bar delta > 0 AND CVD > EMA(CVD, signal lookback)
Short: Highest(high, FA lookback) > Upper band + narrow FA proximity AND Upper band − wide FA proximity < close < Upper band + narrow FA proximity AND Bar delta < 0 AND CVD < EMA(CVD, signal lookback)
Long: low ≤ Lowest(low, divergence lookback) AND CVD > CVD tolerance × Lowest(CVD, divergence lookback) AND CVD > 0
Short: high ≥ Highest(high, divergence lookback) AND CVD < CVD tolerance × Highest(CVD, divergence lookback) AND CVD < 0
Long: CVD > EMA(CVD, signal lookback)
Short: CVD ≤ EMA(CVD, signal lookback)
Long: CVD ≥ 0
Short: CVD < 0
Long: Bar delta ≥ 0
Short: Bar delta < 0
Long: close ≥ VWAP
Short: close < VWAP