Calculation: Long risk = MIN(entry price - long entry signal bar low, entry price × maximum risk percent / 100)
Calculation: Short risk = MIN(short entry signal bar high - entry price, entry price × maximum risk percent / 100)
Calculation: Entry signal bar range percent = (entry signal bar high - entry signal bar low) / entry signal bar low × 100
Calculation: Target risk multiple = IF(entry signal bar range percent > range threshold, larger-range target multiple, otherwise target multiple)
Calculation: Long stop = entry price - long risk
Calculation: Long target = entry price + target risk multiple × long risk
Calculation: Short stop = entry price + short risk
Calculation: Short target = entry price - target risk multiple × short risk
Long: EMA(close, shortest lookback)[1] < EMA(close, middle lookback)[1] AND EMA(close, shortest lookback)[1] < EMA(close, longest lookback)[1] AND EMA(close, shortest lookback) > EMA(close, middle lookback) AND EMA(close, shortest lookback) > EMA(close, longest lookback) AND volume > SMA(volume, volume lookback)
Short: EMA(close, shortest lookback)[1] > EMA(close, middle lookback)[1] AND EMA(close, shortest lookback)[1] > EMA(close, longest lookback)[1] AND EMA(close, shortest lookback) < EMA(close, middle lookback) AND EMA(close, shortest lookback) < EMA(close, longest lookback) AND volume > SMA(volume, volume lookback)
Exit: Long, low <= long stop OR high >= long target OR Hour(datetime) = exit hour AND Minute(datetime) >= exit minute
Exit: Short, high >= short stop OR low <= short target OR Hour(datetime) = exit hour AND Minute(datetime) >= exit minute