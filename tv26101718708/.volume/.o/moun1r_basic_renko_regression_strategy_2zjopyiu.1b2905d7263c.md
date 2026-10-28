Calculation: Linear regression value = linear regression of close over a lookback, with an offset.
Calculation: Pivot low = a confirmed close pivot lower than closes over the configured bars before and after it.
Calculation: Renko close = close of ATR-sized Renko bars built from the instrument at the evaluated chart timeframe.
Long: linear regression value crosses below pivot low AND close > volume-weighted moving average AND rate of change of Renko close < 0
Short: VWAP crosses below linear regression value
Exit: Long, VWAP crosses below linear regression value OR linear regression value crosses pivot low OR close < volume-weighted moving average