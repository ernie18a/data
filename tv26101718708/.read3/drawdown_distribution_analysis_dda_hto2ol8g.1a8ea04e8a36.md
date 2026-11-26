Calculation: Drawdown(source) = 100 × (source - all-time high(source)) / all-time high(source)
Long: Z-score(Drawdown(source), lookback) < -z-score threshold
Exit: long, Z-score(Drawdown(source), lookback) > z-score threshold OR (bars since first bar >= lookback AND percent rank(EMA(Drawdown(source), smoothing lookback), lookback) < 100 - high-risk threshold)