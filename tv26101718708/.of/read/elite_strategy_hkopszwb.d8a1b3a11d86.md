Calculation: Bullish MTF count = number of the six configured timeframes where close is above its EMA; use each timeframe’s latest available bar (forming in real time, completed historically), whether that timeframe is higher or lower than the chart timeframe.
Calculation: Bearish MTF count = number of the six configured timeframes where close is below its EMA; use the same EMA lookback and bar selection as for the bullish count.
Long: Supertrend direction changes from bearish to bullish AND (MTF filter disabled OR bullish MTF count >= configured minimum) AND configured session filter passes (or all sessions are allowed) AND trade direction permits long.
Short: Supertrend direction changes from bullish to bearish AND (MTF filter disabled OR bearish MTF count >= configured minimum) AND configured session filter passes (or all sessions are allowed) AND trade direction permits short.
Exit: long, Short condition.
Exit: short, Long condition.