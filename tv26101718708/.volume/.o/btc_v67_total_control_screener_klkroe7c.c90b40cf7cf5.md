Calculation: Heikin-Ashi close = (open + high + low + close) / 4
Calculation: Heikin-Ashi open = (previous Heikin-Ashi open + previous Heikin-Ashi close) / 2; initialize as (open + close) / 2
Calculation: POC = close of the bar whose volume equals the highest volume in the rolling lookback; update when that condition holds and otherwise retain the previous POC
Long: close crosses above HMA AND Heikin-Ashi close > Heikin-Ashi open AND close > SuperTrend line AND volume >= short-term average volume × volume multiplier AND (close > POC OR close > EMA) AND RSI < upper threshold AND CCI > 0
Long: close crosses above daily HMA AND daily RSI > 50, using daily bars (last completed bar historically; forming bar in real time)
Short: close crosses below daily HMA AND daily RSI < 45, using daily bars (last completed bar historically; forming bar in real time)
Exit: long, close crosses below SuperTrend line OR (close crosses below HMA AND RSI > upper threshold)