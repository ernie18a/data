Calculation: Close z-score = (close − simple moving average of close) / sample standard deviation of close over the same lookback.
Calculation: Relative volume = signal bar volume / mean volume of bars opening at the same time of day on the most recent available prior trading days, up to a lookback; undefined unless a minimum number of days is available and the mean is nonzero.
Calculation: ATR-normalized MACD histogram = (MACD line − exponential moving average of the MACD line) / Wilder ATR, where the MACD line is the shorter-period exponential moving average of close minus the longer-period exponential moving average of close.
Long: No position is open AND the previous bar's opening weekday is an allowed weekday AND its opening hour is within the configured signal window AND its close z-score > threshold AND its relative volume < threshold AND its ATR-normalized MACD histogram < threshold AND its ATR > 0; enter at the current bar's open.
Exit: Long, low <= entry price − stop multiplier × ATR of the signal bar.
Exit: Long, high >= entry price + target multiplier × ATR of the signal bar.
Exit: Long, bars elapsed since entry >= maximum holding bars.
Exit: Long, current server time >= configured daily closing time.