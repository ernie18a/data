Calculation: Long stop = entry-signal bar low − stop buffer
Calculation: Long target = entry-signal bar close + risk/reward multiple × |entry-signal bar close − long stop|
Calculation: Short stop = entry-signal bar high + stop buffer
Calculation: Short target = entry-signal bar close − risk/reward multiple × |short stop − entry-signal bar close|
Long: datetime >= configured start time AND position is flat AND bars since most recent entry >= cooldown period AND entry-signal bar low > long-term EMA(close) AND entry-signal bar close > VWAP(hlc3) AND ADX > threshold AND ADX > its short-term simple moving average AND fast RSI crosses above slow RSI
Short: datetime >= configured start time AND position is flat AND bars since most recent entry >= cooldown period AND entry-signal bar high < long-term EMA(close) AND entry-signal bar close < VWAP(hlc3) AND ADX > threshold AND ADX > its short-term simple moving average AND fast RSI crosses below slow RSI
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target