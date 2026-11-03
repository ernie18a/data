Calculation: MACD line = shorter-lookback EMA(close) − longer-lookback EMA(close); signal line = EMA of MACD line; MACD histogram = MACD line − signal line
Calculation: Trend pulse = max(0, sensitivity × (current MACD line − previous MACD line)), using shorter- and longer-lookback EMAs
Calculation: Bollinger Band width = upper Bollinger Band − lower Bollinger Band
Calculation: Entry ATR = ATR on the entry bar
Calculation: Long stop = entry price − (entry ATR × loss multiple); when max(current close, previous close) > entry price + (entry ATR × loss multiple), set it to entry price. If this value is below max(current close − 2 × entry ATR × trailing multiple, previous long stop or 0), set it to the maximum of those three values and position average price.
Calculation: Short stop = entry price + (entry ATR × loss multiple)
Long: position is flat or short AND datetime is within the configured backtest date range AND MACD histogram crosses above zero AND MACD line > 0 AND Trend pulse > Bollinger Band width
Exit: Long, low <= Long stop
Exit: Short, high >= Short stop OR (MACD histogram crosses above zero AND MACD line > 0)