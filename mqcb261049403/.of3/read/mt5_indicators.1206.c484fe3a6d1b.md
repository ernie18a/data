Calculation: relative vigor spread = RVI(open, high, low, close, fast lookback) - TRVI(open, high, low, close, slow lookback)
Calculation: spread signal line = EMA(relative vigor spread, signal lookback)
Long: relative vigor spread > 0 OR relative vigor spread > spread signal line[1] OR relative vigor spread[1] < spread signal line[2] AND relative vigor spread[2] > spread signal line[3]
Short: relative vigor spread < 0 OR relative vigor spread < spread signal line[1] OR relative vigor spread[1] > spread signal line[2] AND relative vigor spread[2] < spread signal line[3]