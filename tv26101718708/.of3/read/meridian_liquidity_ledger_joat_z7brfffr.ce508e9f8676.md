Calculation: Imbalance = (SUM(volume where close >= open, lookback) - SUM(volume where close < open, lookback)) / SUM(volume, lookback)
Calculation: Reference = EMA(close, reference length) + IF(anchor band enabled, IF(close >= EMA(close, reference length), -1, 1) * band factor * reference bias * STDEV(close, deviation length), 0)
Calculation: Outer band = outer band multiplier * STDEV(close, deviation length)
Calculation: Range position = (Reference - LOWEST(low, lookback)) / (HIGHEST(high, lookback) - LOWEST(low, lookback))
Calculation: Bin size = (HIGHEST(high, lookback) - LOWEST(low, lookback)) / bin count
Calculation: Bin(k) = MIN(FLOOR(((high[k] + low[k] + close[k]) / 3 - LOWEST(low, lookback)) / Bin size), bin count - 1)
Calculation: Bin volume(i) = SUM(volume[k] where Bin(k) = i, for k from 0 to lookback - 1)
Calculation: Peak bin volume = MAX(Bin volume(i), for i from 0 to bin count - 1)
Calculation: Bin midpoint(i) = LOWEST(low, lookback) + (i + 0.5) * Bin size
Calculation: POC price = Bin midpoint(lowest i where Bin volume(i) = Peak bin volume)
Long: bar is confirmed AND Imbalance > dominance threshold AND close >= Reference
Short: bar is confirmed AND Imbalance < -dominance threshold AND close <= Reference
Long: bar is confirmed AND close > Reference + Outer band AND Imbalance > 0
Short: bar is confirmed AND close < Reference - Outer band AND Imbalance < 0
Long: close >= Reference
Short: close < Reference
Long: exists bin i where Bin volume(i) >= minimum shelf strength * Peak bin volume AND Bin midpoint(i) < Reference
Short: exists bin i where Bin volume(i) >= minimum shelf strength * Peak bin volume AND Bin midpoint(i) >= Reference
Long: POC price < Reference
Short: POC price >= Reference
Long: Imbalance >= 0
Short: Imbalance < 0
Long: close >= POC price
Short: close < POC price
Long: Range position < range share threshold
Short: Range position >= range share threshold