Calculation: Keltner middle = EMA(close, lookback)
Calculation: Keltner upper/lower = Keltner middle ± EMA(true range, same lookback) × channel multiplier
Long: open > Keltner lower AND open < Keltner upper AND close > Keltner upper AND +DI > −DI AND +DI > trigger level AND volume > previous bar volume AND (ribbon filter disabled OR EMA(close, lookback) > SMA(close, same lookback))
Exit: long, high ≥ entry price × (1 + first long profit target)
Exit: long, high ≥ entry price × (1 + second long profit target)
Exit: long, close < Keltner middle