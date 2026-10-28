Calculation: Long stop = lowest low over the swing lookback ending on the signal bar
Calculation: Long target = signal-bar close + (signal-bar close − long stop) × risk/reward
Calculation: Short stop = highest high over the swing lookback ending on the signal bar
Calculation: Short target = signal-bar close − (short stop − signal-bar close) × risk/reward
Long: time is within the configured session AND volume > volume SMA AND low <= current-timeframe EMA AND trend-timeframe close > its EMA AND setup-timeframe close > its EMA AND close > open AND close > previous bar high AND close > long stop AND position is flat or short
Short: time is within the configured session AND volume > volume SMA AND high >= current-timeframe EMA AND trend-timeframe close < its EMA AND setup-timeframe close < its EMA AND close < open AND close < previous bar low AND short stop > close AND position is flat or long
Exit: Long, low <= long stop OR high >= long target
Exit: Short, high >= short stop OR low <= short target