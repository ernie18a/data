Calculation: Swing levels = On each bar, confirm a swing high or low when the high or low at the center of a symmetric lookback window equals the highest high or lowest low of that window; retain the most recently confirmed level of each kind.
Calculation: Swing trend = Initially neutral; set to up when close exceeds the latest swing high, then set to down when close is below the latest swing low; otherwise retain the previous trend.
Calculation: Profit target = Signal-bar close plus, for a long, or minus, for a short, an ATR-based distance calculated on the signal bar; use three successively higher multiples of that distance and disable each target after it is reached.
Long: Swing trend is up AND latest swing low exists.
Short: Swing trend is down AND latest swing high exists.
Exit: long, swing trend is down.
Exit: short, swing trend is up.
Exit: long, percentage return from entry price to close is below the stop-loss threshold AND shorter EMA of close is greater than or equal to longer EMA of close.
Exit: long, high exceeds an enabled profit target.
Exit: short, low is below an enabled profit target.