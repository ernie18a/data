Calculation: Short MA = simple moving average of close with a shorter lookback than the long MA
Calculation: Long MA = simple moving average of close with a longer lookback than the short MA
Long: Previous close <= both MAs AND current close > both MAs OR current close > short MA AND current close < long MA
Short: Previous close >= both MAs AND current close < both MAs OR current close < short MA AND current close > long MA
Exit: Long, low <= short MA AND close < short MA
Exit: Short, high >= short MA AND close > short MA