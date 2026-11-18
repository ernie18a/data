Calculation: Relative volume = volume / SMA(volume, average-volume lookback)
Long: close[1] crosses above highest(high, breakout lookback)[2] AND close[1] > VWAP(close)[1] AND EMA(close, shorter EMA lookback)[1] > EMA(close, longer EMA lookback)[1] AND Relative volume[1] > entry relative-volume threshold
Exit: long, close[1] crosses below EMA(close, shorter EMA lookback)[1]
Exit: long, high[1] - max(open[1], close[1]) > wick-body multiple × abs(open[1] - close[1]) AND Relative volume[1] > exhaustion relative-volume threshold AND NOT (close[1] crosses below EMA(close, shorter EMA lookback)[1])