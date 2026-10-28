Calculation: Opening Range High/Low = maximum high/minimum low over the configured ORB build window; use the last completed window.
Calculation: 5-minute RSI = RSI of 5-minute closes, using the latest available 5-minute bar (last completed bar in historical backtests).
Calculation: Entry-timeframe RSI = RSI of closes on the configured entry timeframe, using the latest available bar (last completed bar in historical backtests).
Calculation: Candle delta = volume × sign(close − open)
Calculation: Smoothed candle delta = EMA of candle delta
Calculation: Daily cumulative delta = sum of candle delta since the start of the day
Long: close crosses above Opening Range High OR (long breakout is armed and low ≤ Opening Range High and close > Opening Range High) OR (long breakout and long filters pass and entry filters pass) OR (long retest and long filters pass and entry filters pass)
Short: close crosses below Opening Range Low OR (short breakout is armed and high ≥ Opening Range Low and close < Opening Range Low) OR (short breakout and short filters pass and entry filters pass) OR (short retest and short filters pass and entry filters pass)
Exit: Long, low ≤ current stop OR high ≥ final active take-profit OR (enabled and close < Opening Range High) OR (enabled and close < VWAP) OR (enabled and trading session has just ended)
Exit: Short, high ≥ current stop OR low ≤ final active take-profit OR (enabled and close > Opening Range Low) OR (enabled and close > VWAP) OR (enabled and trading session has just ended)