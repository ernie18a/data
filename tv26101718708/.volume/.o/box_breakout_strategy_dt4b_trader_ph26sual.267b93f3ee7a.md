Calculation: Box high = highest high over the preceding lookback bars, excluding the current bar
Calculation: Box low = lowest low over the preceding lookback bars, excluding the current bar
Long: close > Box high AND volume > volume moving average
Short: close < Box low AND volume > volume moving average
Exit: long, low <= entry price - ATR × stop multiplier OR high >= entry price + ATR × stop multiplier × risk/reward
Exit: short, high >= entry price + ATR × stop multiplier OR low <= entry price - ATR × stop multiplier × risk/reward