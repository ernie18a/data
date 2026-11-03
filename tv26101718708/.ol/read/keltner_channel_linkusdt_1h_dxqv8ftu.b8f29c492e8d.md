Calculation: Upper Keltner Channel = EMA(close, lookback) + EMA(true range, same lookback) × multiplier
Calculation: Middle Keltner Channel = EMA(close, lookback)
Long: open > lower Keltner Channel AND open < upper Keltner Channel AND close > upper Keltner Channel AND +DI > -DI AND +DI > trigger level AND volume > previous bar's volume AND (ribbon filter disabled OR EMA(close, lookback) > SMA(close, same lookback))
Exit: Long, high >= entry price × (1 + first profit target percentage)
Exit: Long, high >= entry price × (1 + second profit target percentage)
Exit: Long, close < middle Keltner Channel