Calculation: VWAP deviation z-score = (close − VWAP − SMA(close − VWAP, deviation lookback)) / standard deviation(close − VWAP, same lookback); use 0 when the standard deviation is 0
Calculation: Short deviation threshold = long deviation threshold + optional extra short deviation; use the same deviation lookback for both
Calculation: Higher-timeframe EMA = EMA of close on the configured higher timeframe, using the last completed higher-timeframe bar
Calculation: Volatility condition = current-timeframe ATR > SMA of current-timeframe ATR × volatility threshold; the ATR lookback is shorter than the ATR-SMA lookback
Calculation: Long stop = entry price − current-timeframe ATR × stop multiple
Calculation: Short stop = entry price + current-timeframe ATR × stop multiple
Calculation: Long target = max(VWAP, entry price + (entry price − long stop) × target multiple)
Calculation: Short target = min(VWAP, entry price − (short stop − entry price) × target multiple)
Long: datetime is within the configured session AND cooldown is off or no exit has occurred yet or bars since the most recent exit are at least the configured cooldown AND volatility condition is disabled or true AND higher-timeframe trend filter is disabled or close ≥ higher-timeframe EMA AND VWAP deviation z-score ≤ −long deviation threshold AND RSI ≤ oversold threshold
Short: shorts are enabled AND datetime is within the configured session AND cooldown is off or no exit has occurred yet or bars since the most recent exit are at least the configured cooldown AND volatility condition is disabled or true AND higher-timeframe trend filter is disabled or close ≤ higher-timeframe EMA AND VWAP deviation z-score ≥ short deviation threshold AND RSI ≥ overbought threshold
Exit: Long, low ≤ long stop OR high ≥ long target OR time stop is enabled and bars since entry are at least the configured time stop
Exit: Short, high ≥ short stop OR low ≤ short target OR time stop is enabled and bars since entry are at least the configured time stop