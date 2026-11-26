Calculation: long stop = long-signal-bar close - ATR(ATR lookback) * stop multiplier
Calculation: long target = long-signal-bar close + (long-signal-bar close - long stop) * reward-risk ratio
Calculation: short stop = short-signal-bar close + ATR(ATR lookback) * stop multiplier
Calculation: short target = short-signal-bar close - (short stop - short-signal-bar close) * reward-risk ratio
Long: close > highest(high[1], box lookback) AND (volume confirmation disabled OR volume > SMA(volume, volume-average lookback))
Short: close < lowest(low[1], box lookback) AND (volume confirmation disabled OR volume > SMA(volume, volume-average lookback))
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target