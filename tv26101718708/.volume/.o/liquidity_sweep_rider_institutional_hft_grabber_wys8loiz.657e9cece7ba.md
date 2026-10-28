Calculation: Latest confirmed swing low = the low of the most recent pivot low, lower than the lows of the preceding left lookback bars and following right lookback bars; retain until a newer pivot low is confirmed
Calculation: Latest confirmed swing high = the high of the most recent pivot high, higher than the highs of the preceding left lookback bars and following right lookback bars; retain until a newer pivot high is confirmed
Calculation: Cooldown = 2 × the greater of the sum of pivot left and right lookbacks or 5 bars
Long: low < latest confirmed swing low AND close > latest confirmed swing low AND volume >= volume SMA × volume multiplier AND bars since the previous long sweep > cooldown
Short: high > latest confirmed swing high AND close < latest confirmed swing high AND volume >= volume SMA × volume multiplier AND bars since the previous short sweep > cooldown
Exit: long, low <= entry price − ATR × stop multiplier OR high >= entry price + ATR × stop multiplier × risk-reward ratio
Exit: short, high >= entry price + ATR × stop multiplier OR low <= entry price − ATR × stop multiplier × risk-reward ratio