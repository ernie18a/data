Calculation: candle body = abs(close - open)
Calculation: prior maximum candle body = max(candle body over a parameter lookback ending two bars ago)
Long: close[1] > open[1] AND ATR(ATR lookback, chart bars, last completed bar) > multiplier × SMA(ATR(same ATR lookback, T1 values), averaging lookback, evaluated on chart bars taking values from T1, last completed chart bar)
Short: close[1] < open[1] AND ATR(ATR lookback, chart bars, last completed bar) > multiplier × SMA(ATR(same ATR lookback, T1 values), averaging lookback, evaluated on chart bars taking values from T1, last completed chart bar)
Long: close[2] < Ichimoku Senkou Span A(parameters)[1] AND close[2] < Ichimoku Senkou Span B(same parameters)[1] AND close[1] > Ichimoku Senkou Span A(parameters)[1] AND close[1] > Ichimoku Senkou Span B(same parameters)[1]
Short: close[2] > Ichimoku Senkou Span A(parameters)[1] AND close[2] > Ichimoku Senkou Span B(same parameters)[1] AND close[1] < Ichimoku Senkou Span A(parameters)[1] AND close[1] < Ichimoku Senkou Span B(same parameters)[1]
Long: close[1] > open[1] AND candle body[1] > multiplier × prior maximum candle body
Short: close[1] < open[1] AND candle body[1] > multiplier × prior maximum candle body
Exit: long, close[2] > Parabolic SAR(parameters)[2] AND close[1] < Parabolic SAR(same parameters)[1]
Exit: short, close[2] < Parabolic SAR(parameters)[2] AND close[1] > Parabolic SAR(same parameters)[1]