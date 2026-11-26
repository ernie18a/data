Calculation: EmaGap = |EMA(close, shorter EMA length) - EMA(close, longer EMA length)| / ATR(ATR length)
Calculation: PriceDispersion = StDev(close, stdev length) / close
Calculation: RangeRatio = (Highest(high, feature length) - Lowest(low, feature length)) / ATR(ATR length)
Calculation: FastSlope = |EMA(close, shorter EMA length) - EMA(close, shorter EMA length)[feature length]| / (ATR(ATR length) * feature length)
Calculation: Scaled(x) = (x - Lowest(x, training length)) / (Highest(x, training length) - Lowest(x, training length)) if Highest(x, training length) is greater than Lowest(x, training length) AND x is defined; otherwise the scale midpoint
Calculation: Point = (Scaled(EmaGap), Scaled(PriceDispersion), Scaled(RangeRatio), Scaled(FastSlope))
Calculation: Clusters = K-means cluster centers of Point over bars back 0 to training length - 1, with K = regime count; when no clusters exist, cluster i (i = 0 to K - 1) is initialized at Point[min(round(training length * i / (K - 1)), training length - 1)]; each refit runs K-means iterations, where each iteration assigns every Point in the window to its nearest cluster by Euclidean distance and sets each cluster to the mean of its assigned Points (unchanged if none assigned); refit every refit interval bars
Calculation: ClusterRegime(c) = Trend if first + fourth >= second AND first + fourth >= 1 - third - first; otherwise Volatile if second >= 1 - third - first; otherwise Range, where first to fourth are the coordinates of c in Point order
Calculation: Regime = Range if no clusters exist; otherwise ClusterRegime(nearest cluster to Point by Euclidean distance)
Calculation: Midline = (Highest(high, range length) + Lowest(low, range length)) / 2 if Regime = Range; LinearRegression(close, trend length, 0) if Regime = Trend; EMA(close, volatile length) if Regime = Volatile
Calculation: ResidualRMS(length) = sqrt(sum over i = 0 to length - 1 of (close[i] - LinearRegression(close, length, i))^2 / length)
Calculation: Halfwidth = max((Highest(high, range length) - Lowest(low, range length)) / 2 * range half-span factor, ATR(ATR length) * range width multiple) if Regime = Range; max(ResidualRMS(trend length), ATR(ATR length) * trend width multiple) if Regime = Trend; ATR(ATR length) * volatile width multiple if Regime = Volatile
Calculation: UpRun = if close > Midline + Halfwidth + ATR(ATR length) * breakout multiple then UpRun[1] + 1 else 0
Calculation: DownRun = if close < Midline - Halfwidth - ATR(ATR length) * breakout multiple then DownRun[1] + 1 else 0
Long: UpRun = confirmation bars
Short: DownRun = confirmation bars