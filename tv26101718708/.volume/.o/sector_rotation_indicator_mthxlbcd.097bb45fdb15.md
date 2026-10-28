Calculation: Asset momentum score = (short-term EMA of the asset’s close / long-term EMA of its close − 1) × 100, using daily bars and the latest available daily bar
Calculation: Kernel trend value = the average percentage deviation of the close from three trailing weighted averages, using Epanechnikov, logistic, and wave weights; compare it with a longer-lookback SMA of that value, using chart bars (or daily bars when configured for daily kernel data)
Calculation: Systematic risk score = smoothed tail-risk score from SPX daily bars: for each of YoY return, 63-session positive-day fraction, distance above/below SMA200 in ATR200 units, and 63-session return divided by ATR63/SMA63, take the higher of its short- and long-lookback historical percentile ranks; combine the four ranks using their 70th percentile plus a penalty when the maximum exceeds 85, then invert and smooth the result
Long: Kernel trend value > its longer-lookback SMA
Long: Switch to the eligible asset with the highest asset momentum score when it leads the active asset; with three or more assets in a bull market, require its score to exceed the active asset’s score by the configured percentage buffer
Short: Kernel trend value < its longer-lookback SMA
Exit: Long, the active asset is switched to another asset by the asset momentum rotation rule
Exit: Long, average 14-period RSI of SPX, IXT, and IXR < the configured low-RSI threshold
Exit: Long, systematic risk score ≥ its critical threshold plus zone offset AND SPX close < EMA80 OR SPX close ≤ SMA200 AND IXR momentum score > IXT momentum score