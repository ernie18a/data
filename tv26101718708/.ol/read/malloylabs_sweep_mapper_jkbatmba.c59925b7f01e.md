Calculation: Pivot liquidity zones = confirmed pivot highs (resistance) and lows (support), using equal left and right lookbacks; merge a new pivot into the first existing zone whose level is within the merge threshold by replacing its level with the average and incrementing its touch count, otherwise create a zone with one touch; discard oldest zones beyond the maximum count. A zone is unswept until a qualifying sweep with volume confirmation.
Calculation: Zone half-width = zone level × zone-width percentage ÷ 2.
Calculation: Minimum wick penetration = level × minimum-wick percentage.
Calculation: Volume spike = volume > simple moving average of volume over a longer lookback × volume multiplier.
Long: An unswept support zone has low < zone level − zone half-width − minimum wick penetration AND close > zone level AND close > open AND volume spike AND close > the middle-length EMA
Long: OR low < any of the short-, middle-, or long-length EMAs − minimum wick penetration AND close > that EMA AND close > open AND volume spike
Short: An unswept resistance zone has high > zone level + zone half-width + minimum wick penetration AND close < zone level AND close < open AND volume spike AND close < the middle-length EMA
Short: OR high > any of the short-, middle-, or long-length EMAs + minimum wick penetration AND close < that EMA AND close < open AND volume spike