Calculation: Volume confirmation = volume filter disabled OR (volume is available AND SMA(volume, volume MA lookback) is available AND volume > SMA(volume, volume MA lookback))
Calculation: First range touch(level) = a prior chart bar exists AND low <= level AND high >= level AND NOT (low[1] <= level[1] AND high[1] >= level[1])
Long: EMA(price source, fast lookback) crosses above EMA(price source, slow lookback) AND Volume confirmation
Short: EMA(price source, fast lookback) crosses below EMA(price source, slow lookback) AND Volume confirmation
Long: First range touch(EMA(price source, fast lookback)) AND close[1] <= EMA(price source, fast lookback)[1]
Short: First range touch(EMA(price source, fast lookback)) AND close[1] > EMA(price source, fast lookback)[1]
Long: First range touch(EMA(price source, slow lookback)) AND close[1] <= EMA(price source, slow lookback)[1]
Short: First range touch(EMA(price source, slow lookback)) AND close[1] > EMA(price source, slow lookback)[1]
Long: First range touch(VWAP(price source)) AND close[1] <= VWAP(price source)[1]
Short: First range touch(VWAP(price source)) AND close[1] > VWAP(price source)[1]