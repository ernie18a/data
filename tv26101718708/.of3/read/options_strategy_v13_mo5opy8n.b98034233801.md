Calculation: long setup = true when EMA(close, shorter lookback) crosses above EMA(close, longer lookback); false when it crosses below or a long entry occurs
Calculation: short setup = true when EMA(close, shorter lookback) crosses below EMA(close, longer lookback); false when it crosses above or a short entry occurs
Calculation: opening-range high = maximum high during the opening-range interval
Calculation: opening-range low = minimum low during the opening-range interval
Calculation: long stop = entry-signal-bar close - ATR(lookback) on the entry-signal bar * stop multiple
Calculation: long target = entry-signal-bar close + ATR(lookback) on the entry-signal bar * stop multiple * target-to-stop ratio
Calculation: short stop = entry-signal-bar close + ATR(lookback) on the entry-signal bar * stop multiple
Calculation: short target = entry-signal-bar close - ATR(lookback) on the entry-signal bar * stop multiple * target-to-stop ratio
Long: long side enabled AND long setup AND RSI(close, lookback) >= long RSI threshold AND (opening-range filter disabled OR close > opening-range high)
Short: short side enabled AND short setup AND RSI(close, lookback) <= short RSI threshold AND (opening-range filter disabled OR close < opening-range low)
Exit: long, on a bar after the entry-signal bar, low <= long stop OR high >= long target OR (bar confirmed AND EMA(close, shorter lookback)[1] > EMA(close, longer lookback)[1] AND EMA(close, shorter lookback) < EMA(close, longer lookback)) OR (bar confirmed at the configured session-close time)
Exit: short, on a bar after the entry-signal bar, high >= short stop OR low <= short target OR (bar confirmed AND EMA(close, shorter lookback)[1] < EMA(close, longer lookback)[1] AND EMA(close, shorter lookback) > EMA(close, longer lookback)) OR (bar confirmed at the configured session-close time)