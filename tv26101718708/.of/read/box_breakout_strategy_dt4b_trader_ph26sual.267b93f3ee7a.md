Calculation: Box high = highest high over the lookback bars before the current bar
Calculation: Box low = lowest low over the lookback bars before the current bar
Long: close > Box high AND volume > average volume
Short: close < Box low AND volume > average volume
Exit: Long, low <= close - ATR * stop multiplier OR high >= close + ATR * stop multiplier * risk-reward
Exit: Short, high >= close + ATR * stop multiplier OR low <= close - ATR * stop multiplier * risk-reward