Calculation: Long stop = entry price − min(entry price − low of the most recent long-signal bar recorded while flat, entry price × maximum risk percentage ÷ 100)
Calculation: Long target = entry price + 2 × (entry price − long stop)
Calculation: Short stop = entry price + min(high of the most recent short-signal bar recorded while flat − entry price, entry price × maximum risk percentage ÷ 100)
Calculation: Short target = entry price − 2 × (short stop − entry price)
Long: close ≥ upper Bollinger Band AND previous bar close < current upper Bollinger Band AND RSI > 60 AND volume > its simple moving average AND close > EMA AND ADX > threshold AND ADX > previous bar ADX AND +DI > −DI
Short: close ≤ lower Bollinger Band AND previous bar close > current lower Bollinger Band AND RSI < 40 AND volume > its simple moving average AND close < EMA AND ADX > threshold AND ADX > previous bar ADX AND −DI > +DI
Exit: Long, low ≤ long stop OR high ≥ long target OR hour(datetime) = configured exit hour AND minute(datetime) ≥ configured exit minute
Exit: Short, high ≥ short stop OR low ≤ short target OR hour(datetime) = configured exit hour AND minute(datetime) ≥ configured exit minute