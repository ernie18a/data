Calculation: sma = simple moving average of the source price over length bars
Calculation: vwap = cumulative sum of ((high + low + close) / 3 × volume) divided by cumulative sum of volume, both from the start of the current session through the current bar
Long: sma > vwap AND previous sma <= previous vwap
Exit: long, sma < vwap AND previous sma >= previous vwap