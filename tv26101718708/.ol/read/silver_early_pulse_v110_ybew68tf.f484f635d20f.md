Calculation: MACD histogram = 12-period EMA of close minus 26-period EMA of close, minus the 9-period EMA of that difference
Calculation: Higher-timeframe EMA = 100-period EMA of close on a higher timeframe, using the last completed bar
Calculation: Volume average = 20-period SMA of volume
Calculation: Initial stop = entry price adjusted against the position by the stop percentage
Calculation: Profit target = entry price adjusted in the position direction by three times the stop percentage
Calculation: ATR = 14-period ATR
Long: MACD histogram crosses above 0 AND close > higher-timeframe EMA AND volume > volume average AND current UTC time is within the active session
Short: MACD histogram crosses below 0 AND close < higher-timeframe EMA AND volume > volume average AND current UTC time is within the active session
Exit: long, low <= stop OR high >= profit target; when close > entry price + 1.5 × ATR, raise stop to the greater of its current value and entry price + 0.3 × ATR
Exit: short, high >= stop OR low <= profit target; when close < entry price − 1.5 × ATR, lower stop to the lesser of its current value and entry price − 0.3 × ATR