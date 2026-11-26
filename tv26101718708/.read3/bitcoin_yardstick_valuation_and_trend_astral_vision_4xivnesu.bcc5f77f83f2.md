Calculation: Mining valuation Z-score = Z-score(log(market-cap close from T1 / hashrate close from T1), z-score lookback), calculated on chart bars using T1 values from the last completed T1 bar historically and the forming T1 bar in real time
Long: Threshold coloring is active AND Mining valuation Z-score < lower threshold OR slope coloring is active AND EMA(Mining valuation Z-score, smoothing lookback) >= EMA(Mining valuation Z-score, smoothing lookback)[slope lookback]
Short: Threshold coloring is active AND Mining valuation Z-score > upper threshold OR slope coloring is active AND EMA(Mining valuation Z-score, smoothing lookback) < EMA(Mining valuation Z-score, smoothing lookback)[slope lookback]
Calculation: Bitcoin market-cap-to-hash-rate Z-score = Z-score(log(Bitcoin market capitalization on T1 / Bitcoin hash rate on T1), P1 chart bars)
Calculation: Trend slope = (EMA(Bitcoin market-cap-to-hash-rate Z-score, P2) - EMA(Bitcoin market-cap-to-hash-rate Z-score, P2)[P3]) / P3
Long: Extremes mode AND Bitcoin market-cap-to-hash-rate Z-score < P4
Short: Extremes mode AND Bitcoin market-cap-to-hash-rate Z-score > P5
Long: Trend mode AND Trend slope >= 0
Short: Trend mode AND Trend slope < 0