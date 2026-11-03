Calculation: Heikin-Ashi close/open = (open + high + low + close) / 4 and, from the second bar onward, the average of the previous Heikin-Ashi open and close; initial open = (open + close) / 2
Calculation: POC = close of the bar whose volume equals the rolling highest volume; retain the previous POC otherwise
Calculation: Lower-timeframe HMA and RSI = HMA and RSI of lower-timeframe closes, using the still-forming lower-timeframe bar
Long: close crosses above HMA AND Heikin-Ashi close > Heikin-Ashi open AND close > SuperTrend line AND volume >= volume moving average × volume multiplier AND (close > POC OR close > long-term EMA) AND RSI < upper entry limit AND CCI > 0
Long: close crosses above lower-timeframe HMA AND lower-timeframe RSI > neutral level
Long: Heikin-Ashi close > Heikin-Ashi open
Short: close crosses below lower-timeframe HMA AND lower-timeframe RSI < lower signal limit
Short: Heikin-Ashi close < Heikin-Ashi open
Exit: long, close crosses below SuperTrend line OR (close crosses below HMA AND RSI > upper exit limit)