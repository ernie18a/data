Calculation: Range bounds = highest high and lowest low over the lookback ending at the signal bar; offset = their difference multiplied by a shift fraction.
Calculation: Trend = initially neutral; on each completed signal bar, set it to short when close < lowest low + offset AND prior trend != short; otherwise set it to long when close > highest high - offset AND prior trend != long; otherwise retain the prior trend. Evaluate the short condition first.
Long: Signal-bar close > highest high - offset AND prior trend != long AND NOT (signal-bar close < lowest low + offset AND prior trend != short).
Short: Signal-bar close < lowest low + offset AND prior trend != short.
Exit: long, trend = short OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, trend = long OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.