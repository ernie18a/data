Calculation: Momentum = (RSI(close, momentum length) + MFI((high + low + close) / 3, momentum length)) / 2
Calculation: TrendState = IF(Momentum > bull threshold AND EMA(close, EMA length) > EMA(close, EMA length)[1], 1, IF(Momentum < bear threshold AND EMA(close, EMA length) < EMA(close, EMA length)[1], -1, TrendState[1]))
Long: TrendState = 1 AND TrendState[1] != 1 AND bar datetime in Asia session
Short: TrendState = -1 AND TrendState[1] != -1 AND bar datetime in Asia session
Long: TrendState = 1
Short: TrendState = -1
Long: Momentum > bull threshold AND EMA(close, EMA length) > EMA(close, EMA length)[1]
Short: Momentum < bear threshold AND EMA(close, EMA length) < EMA(close, EMA length)[1]