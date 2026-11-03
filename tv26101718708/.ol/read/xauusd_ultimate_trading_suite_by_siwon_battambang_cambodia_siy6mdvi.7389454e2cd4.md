Calculation: Running high = highest high since the previous signal, initialized at the first bar and reset to the signal bar's high
Calculation: Running low = lowest low since the previous signal, initialized at the first bar and reset to the signal bar's low
Calculation: Daily pivot = (high + low + close) / 3 of the previous completed daily bar (higher timeframe)
Calculation: Daily open = open of the current, still-forming daily bar (higher timeframe)
Long: (the previous signal was not long) AND (running high - low >= minimum move threshold) AND close > open AND (EMA filter disabled OR close > long-term EMA) OR short-term EMA crosses above VWAP OR (close > daily open AND close > daily pivot)
Short: (the previous signal was not short) AND (high - running low >= minimum move threshold) AND close < open AND (EMA filter disabled OR close < long-term EMA) OR short-term EMA crosses below VWAP OR (close < daily open AND close < daily pivot)