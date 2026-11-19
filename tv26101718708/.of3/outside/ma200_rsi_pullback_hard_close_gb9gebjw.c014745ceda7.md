Calculation: SPY trend filter passes = SPY trend filter disabled OR SPY close > SMA(SPY close, SPY trend period)
Long: flat AND chart bars since last exit ≥ cooldown period AND traded instrument close > SMA(traded instrument close, instrument trend period) AND RSI(traded instrument close, RSI period) < entry threshold AND SPY trend filter passes AND (VIX filter disabled OR VIX close < VIX threshold)
Exit: Long, RSI(traded instrument close, RSI period) > exit threshold
Exit: Long, traded instrument close < SMA(traded instrument close, instrument trend period)
Exit: Long, traded instrument close ≤ entry price − ATR stop multiplier × ATR(traded instrument high, low, close, ATR period) at entry
Exit: Long, hard close enabled AND NOT SPY trend filter passes