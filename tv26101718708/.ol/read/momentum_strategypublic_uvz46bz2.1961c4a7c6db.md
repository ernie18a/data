Calculation: Long risk = min(entry price − low of the long signal bar, entry price × maximum risk percentage)
Calculation: Short risk = min(high of the short signal bar − entry price, entry price × maximum risk percentage)
Calculation: Long stop = entry price − long risk; long target = entry price + 2 × long risk
Calculation: Short stop = entry price + short risk; short target = entry price − 2 × short risk
Long: close ≥ upper Bollinger Band AND previous close < current upper Bollinger Band AND RSI > its threshold AND volume > its moving average AND close > trend EMA AND ADX > its threshold AND ADX > previous bar ADX AND +DI > −DI
Short: close ≤ lower Bollinger Band AND previous close > current lower Bollinger Band AND RSI < its threshold AND volume > its moving average AND close < trend EMA AND ADX > its threshold AND ADX > previous bar ADX AND −DI > +DI
Exit: long, low ≤ long stop OR high ≥ long target OR hour(datetime) = exit hour AND minute(datetime) ≥ exit minute
Exit: short, high ≥ short stop OR low ≤ short target OR hour(datetime) = exit hour AND minute(datetime) ≥ exit minute