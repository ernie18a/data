Calculation: OB/OS value = if RSI((high - center) / half-range, RSI lookback) and RSI((low - center) / half-range, RSI lookback) are both above the RSI centerline, their maximum; if both are below it, their minimum; otherwise whichever is closer to the centerline, choosing the low-based RSI on a tie; center = RMA(low, OB/OS channel lookback) + half-range; half-range = half the difference between RMA(high, OB/OS channel lookback) and RMA(low, OB/OS channel lookback); undefined when half-range is zero
Calculation: Adaptive overbought level = EMA update of OB/OS value[pivot offset] when OB/OS value[pivot offset] >= Highest(OB/OS value, pivot lookback) and OB/OS value[pivot offset] > upper neutral threshold; initialize with the first qualifying value, otherwise retain the previous level
Calculation: Adaptive oversold level = EMA update of OB/OS value[pivot offset] when OB/OS value[pivot offset] <= Lowest(OB/OS value, pivot lookback) and OB/OS value[pivot offset] < lower neutral threshold; initialize with the first qualifying value, otherwise retain the previous level
Long: RSI(close, RSI lookback) >= RSI centerline AND NOT (RSI(close, RSI lookback) < upper neutral threshold AND RSI(close, RSI lookback) > lower neutral threshold)
Short: RSI(close, RSI lookback) < RSI centerline AND NOT (RSI(close, RSI lookback) < upper neutral threshold AND RSI(close, RSI lookback) > lower neutral threshold)
Long: RSI(close, RSI lookback) > RSI(close, RSI lookback, T1, last completed T1 bar), computed on T1 bars and sampled on chart bars
Short: RSI(close, RSI lookback) < RSI(close, RSI lookback, T1, last completed T1 bar), computed on T1 bars and sampled on chart bars
Long: RSI(close, RSI lookback) > the selected SMA or EMA of RSI(close, RSI lookback) over the shorter fast-average lookback
Short: RSI(close, RSI lookback) < the selected SMA or EMA of RSI(close, RSI lookback) over the shorter fast-average lookback
Long: RSI(close, RSI lookback) > the selected SMA or EMA of RSI(close, RSI lookback) over the longer slow-average lookback
Short: RSI(close, RSI lookback) < the selected SMA or EMA of RSI(close, RSI lookback) over the longer slow-average lookback
Long: the selected SMA or EMA of RSI(close, RSI lookback) over the shorter fast-average lookback > the selected SMA or EMA of RSI(close, RSI lookback) over the longer slow-average lookback
Short: the selected SMA or EMA of RSI(close, RSI lookback) over the shorter fast-average lookback < the selected SMA or EMA of RSI(close, RSI lookback) over the longer slow-average lookback
Long: the selected SMA, EMA, or RMA of OHLC4 over the price-average lookback > RMA(high, channel lookback)
Short: the selected SMA, EMA, or RMA of OHLC4 over the price-average lookback < RMA(low, channel lookback)
Long: OB/OS value > adaptive overbought level
Short: OB/OS value < adaptive oversold level