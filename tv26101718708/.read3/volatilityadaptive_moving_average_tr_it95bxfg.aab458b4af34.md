Calculation: Volatility ratio = ATR(ATR lookback) / MA(ATR(ATR lookback), MA lookback, MA type, factor, sigma, KAMA factor), or 1 when the MA is 0
Calculation: Dynamic period = max(volatility ratio, min(dynamic lookback, SMA(max(volatility ratio, min(dynamic lookback, dynamic lookback − volatility ratio × ratio lookback)), smoothing lookback) when smoothing is enabled, otherwise max(volatility ratio, min(dynamic lookback, dynamic lookback − volatility ratio × ratio lookback)))
Calculation: Adaptive MA = selected variable-length EMA, DEMA, RMA, or TEMA of close using the dynamic period
Long: close crosses above the adaptive MA
Short: close crosses below the adaptive MA