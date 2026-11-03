Calculation: Prior highest close = highest close over a lookback ending on the previous bar
Calculation: Short-term simple moving average = simple moving average with a shorter lookback than the long-term simple moving average
Calculation: Long-term simple moving average = simple moving average with a longer lookback than the short-term simple moving average
Calculation: Long trailing stop = highest close since long entry multiplied by (1 − trailing-stop percentage)
Long: close > prior highest close AND previous close <= the prior bar's prior highest close AND short-term simple moving average of close × short-term simple moving average of volume > a threshold
Exit: long, close crosses below the long-term simple moving average OR low <= long trailing stop