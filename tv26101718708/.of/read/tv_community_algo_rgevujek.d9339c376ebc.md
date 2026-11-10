Calculation: WaveTrend = EMA of the channel index over a smoothing lookback; channel index = (typical price - EMA of typical price) / (scale factor × EMA of the absolute deviation of typical price from that EMA), using the same lookback for both EMAs of typical price and absolute deviation; typical price = (high + low + close) / 3
Calculation: Trend-panel SMA = SMA of close calculated independently on each selected timeframe; for a higher timeframe, use the last completed bar and carry its value forward; for a lower timeframe, use the last completed lower-timeframe bar within each chart bar
Calculation: Signal state = initially neither long nor short; after a WaveTrend long decision set it to long, and after a WaveTrend short decision set it to short
Long: WaveTrend crosses above its shorter-lookback SMA AND signal state is not long
Short: WaveTrend crosses below its shorter-lookback SMA AND signal state is not short
Long: short-term EMA of close crosses above long-term EMA of close
Short: short-term EMA of close crosses below long-term EMA of close
Exit: short, short-term EMA of close crosses above long-term EMA of close
Exit: long, short-term EMA of close crosses below long-term EMA of close
Long: close > SMA of close
Short: close < SMA of close
Long: EMA of close > its value a fixed number of chart bars earlier
Short: EMA of close < its value a fixed number of chart bars earlier
Long: trend-panel SMA > its value on the previous chart bar
Short: trend-panel SMA <= its value on the previous chart bar
Long: close > rolling highest high OR close > rolling lowest low, evaluated separately for each of several lookbacks
Short: close <= rolling highest high OR close <= rolling lowest low, evaluated separately for each of several lookbacks