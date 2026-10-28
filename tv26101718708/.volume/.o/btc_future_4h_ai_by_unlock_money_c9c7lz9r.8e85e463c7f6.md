Calculation: Long stop = the lower of (entry price − ATR × ATR stop multiplier) and (lowest low over the swing lookback × (1 − wick buffer percentage / 100))
Calculation: Short stop = the higher of (entry price + ATR × ATR stop multiplier) and (highest high over the swing lookback × (1 + wick buffer percentage / 100))
Calculation: Long TP1 = entry price + (entry price − long stop) × TP1 risk/reward multiplier
Calculation: Long TP2 = entry price + (entry price − long stop) × TP2 risk/reward multiplier
Calculation: Short TP1 = entry price − (short stop − entry price) × TP1 risk/reward multiplier
Calculation: Short TP2 = entry price − (short stop − entry price) × TP2 risk/reward multiplier
Long: position is flat AND fast EMA > middle EMA > slow EMA AND RSI is within its long range AND Supertrend direction is bullish now and was bearish on the previous bar AND volume > its moving average
Short: position is flat AND fast EMA < middle EMA < slow EMA AND RSI is within its short range AND Supertrend direction is bearish now and was bullish on the previous bar AND volume > its moving average
Exit: Long, low <= long stop OR high >= long TP1 OR high >= long TP2
Exit: Short, high >= short stop OR low <= short TP1 OR low <= short TP2