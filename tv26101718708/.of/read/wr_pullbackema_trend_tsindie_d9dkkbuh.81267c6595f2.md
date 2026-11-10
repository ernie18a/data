Calculation: Fast and slow moving averages = independently selected SMA, EMA, RMA, WMA, or VWMA of independently selected price sources, with the fast average using a shorter lookback than the slow average.
Calculation: Stop buffer = EMA of true range multiplied by a configurable multiplier.
Calculation: Long stop = lower of the signal bar's low and the preceding bar's low minus the stop buffer at the signal bar; fixed when the long signal occurs.
Calculation: Short stop = higher of the signal bar's high and the preceding bar's high plus the stop buffer at the signal bar; fixed when the short signal occurs.
Calculation: Long target = signal bar close + (signal bar close - long stop) multiplied by the risk/reward ratio; fixed when the long signal occurs.
Calculation: Short target = signal bar close - (short stop - signal bar close) multiplied by the risk/reward ratio; fixed when the short signal occurs.
Long: Fast moving average > slow moving average AND Williams %R < oversold threshold.
Long: Fast moving average > slow moving average AND previous Williams %R < oversold threshold AND current Williams %R > oversold threshold.
Long: Long entries enabled = true AND position = flat AND fast moving average > slow moving average AND close > fast moving average AND previous Williams %R < oversold threshold AND current Williams %R > oversold threshold AND bar opening datetime >= start datetime AND bar opening datetime <= end datetime AND (number of enabled sessions = 0 OR bar opening time in UTC is within an enabled session). Place a stop-limit entry with stop and limit both equal to the signal bar close.
Short: Fast moving average < slow moving average AND Williams %R > overbought threshold.
Short: Fast moving average < slow moving average AND previous Williams %R > overbought threshold AND current Williams %R < overbought threshold.
Short: Short entries enabled = true AND position = flat AND fast moving average < slow moving average AND close < fast moving average AND previous Williams %R > overbought threshold AND current Williams %R < overbought threshold AND bar opening datetime >= start datetime AND bar opening datetime <= end datetime AND (number of enabled sessions = 0 OR bar opening time in UTC is within an enabled session). Place a stop-limit entry with stop and limit both equal to the signal bar close.
Exit: long, low <= long stop OR high >= long target.
Exit: short, high >= short stop OR low <= short target.