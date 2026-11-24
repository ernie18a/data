Calculation: Volume force = 0.5 when volume is zero; otherwise 1 when close > open and 0 when close <= open
Calculation: Demand zone A = [confirmed PivotLow(low, A-left lookback, A-right lookback), PivotLow + zone depth × ATR(zone ATR lookback)]
Calculation: Supply zone A = [confirmed PivotHigh - zone depth × ATR(zone ATR lookback), confirmed PivotHigh]
Calculation: Demand zone B = [confirmed PivotLow(low, B-left lookback, B-right lookback), PivotLow + zone depth × ATR(zone ATR lookback)]
Calculation: Supply zone B = [confirmed PivotHigh - zone depth × ATR(zone ATR lookback), confirmed PivotHigh]
Calculation: Cluster POC confluence = when cluster volume profile is enabled, close is within the POC proximity ATR multiplier × ATR(zone ATR lookback) of any POC; for each rolling profile lookback, cluster hl2 values into the parameterized number of clusters by nearest-centroid distance, initialize centroids evenly inside the observed minimum-to-maximum range, update them for the parameterized iterations using volume-weighted means when cluster volume is positive, split each cluster's low-to-high range into the parameterized number of bins, allocate each bar's volume to each bin by wick overlap divided by max(high - low, minimum tick), and use the midpoint of each cluster's highest-volume bin as its POC, choosing the first bin on ties
Calculation: Bull score = 1(close > EMA(close, Gaussian lookback)) + 1(MACD line > signal line) + 1(Volume force > bull threshold) + 1(close is within demand zone A, or if not within A, within demand zone B) + 1(Cluster POC confluence)
Calculation: Bear score = 1(close < EMA(close, Gaussian lookback)) + 1(MACD line < signal line) + 1(Volume force < bear threshold) + 1(close is within supply zone A, or if not within A, within supply zone B) + 1(Cluster POC confluence)
Calculation: Trend direction = EMA(close, fast trend lookback) > EMA(close, slow trend lookback); when HTF use is enabled, both EMAs run on chart bars using close sampled from the still-forming T1 bar, otherwise both use chart close
Long: MACD(fast lookback, slow lookback, signal lookback) line crosses above its signal line AND close > EMA(close, Gaussian lookback) AND Volume force > bull threshold AND (strict mode disabled OR (Bull score >= minimum confirmations AND volume / SMA(volume, volume-average lookback) >= minimum volume ratio when the SMA is positive, otherwise 1 >= minimum volume ratio AND abs(close - EMA(close, Gaussian lookback)) / EMA(close, Gaussian lookback) × 100 <= maximum Gaussian distance percent AND (avoid-chop disabled OR ATR(chop lookback) >= SMA(ATR(chop lookback), ATR-average lookback) × chop threshold))
Short: MACD(fast lookback, slow lookback, signal lookback) line crosses below its signal line AND close < EMA(close, Gaussian lookback) AND Volume force < bear threshold AND (strict mode disabled OR (Bear score >= minimum confirmations AND volume / SMA(volume, volume-average lookback) >= minimum volume ratio when the SMA is positive, otherwise 1 >= minimum volume ratio AND abs(close - EMA(close, Gaussian lookback)) / EMA(close, Gaussian lookback) × 100 <= maximum Gaussian distance percent AND (avoid-chop disabled OR ATR(chop lookback) >= SMA(ATR(chop lookback), ATR-average lookback) × chop threshold))
Long: low < last confirmed PivotLow(low, structure-left lookback, structure-right lookback) AND close > that pivot low AND Volume force > shark-bull threshold
Short: high > last confirmed PivotHigh(high, structure-left lookback, structure-right lookback) AND close < that pivot high AND Volume force < shark-bear threshold
Long: a confirmed PivotLow(low, structure-left lookback, structure-right lookback) is higher than the previously recorded PivotLow
Short: a confirmed PivotHigh(high, structure-left lookback, structure-right lookback) is lower than the previously recorded PivotHigh
Long: MACD line > signal line
Short: MACD line <= signal line
Long: close > EMA(close, Gaussian lookback)
Short: close <= EMA(close, Gaussian lookback)
Long: Volume force > volume-force midpoint threshold
Short: Volume force <= volume-force midpoint threshold
Long: trend filter mode is not Off AND Trend direction
Short: trend filter mode is not Off AND NOT Trend direction
Long: close crosses above EMA(close, Gaussian lookback) when Gaussian-cross alerts are enabled
Short: close crosses below EMA(close, Gaussian lookback) when Gaussian-cross alerts are enabled
Long: high crosses last confirmed PivotHigh(high, structure-left lookback, structure-right lookback)
Short: low crosses last confirmed PivotLow(low, structure-left lookback, structure-right lookback)
Long: demand zone A exists AND high crosses its top
Long: demand zone B exists AND high crosses its top
Short: supply zone A exists AND low crosses its bottom
Short: supply zone B exists AND low crosses its bottom
Calculation: Bullish fair value gap = high[2] < low AND high[2] < high[1] AND low[2] < low AND (low - high[2]) / low × 100 > gap-size threshold
Calculation: Bearish fair value gap = low[2] > high AND low[2] > low[1] AND high[2] > high AND (low[2] - high) / low[2] × 100 > gap-size threshold
Long: fair value gap signals are enabled AND an existing bullish fair value gap's top is crossed above by low AND the current bar does not form a bullish fair value gap
Short: fair value gap signals are enabled AND an existing bearish fair value gap's bottom is crossed below by high AND the current bar does not form a bearish fair value gap
Long: Nadaraya-Watson regression(close, bandwidth, weighting, sample lookback) > its value one bar ago
Short: Nadaraya-Watson regression(close, bandwidth, weighting, sample lookback) <= its value one bar ago
Long: candle coloring is enabled AND low <= Nadaraya-Watson regression(close, bandwidth, weighting, sample lookback) - envelope multiplier × ATR(envelope ATR lookback)
Short: candle coloring is enabled AND high >= Nadaraya-Watson regression(close, bandwidth, weighting, sample lookback) + envelope multiplier × ATR(envelope ATR lookback)