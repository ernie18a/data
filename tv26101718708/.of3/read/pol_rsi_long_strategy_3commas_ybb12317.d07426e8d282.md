Calculation: base entry price = entry price of the order that opened the current position
Calculation: filled safety orders = number of safety order entries made since the current position opened
Long: position side is flat AND datetime >= window start AND datetime <= window end AND RSI(close, lookback, T1, last completed bar) < RSI threshold
Long: position side is long AND filled safety orders = 0 AND datetime >= window start AND datetime <= window end AND close <= base entry price * (1 - safety order 1 deviation percent / 100)
Long: position side is long AND filled safety orders = 1 AND datetime >= window start AND datetime <= window end AND close <= base entry price * (1 - safety order 2 deviation percent / 100)
Long: position side is long AND filled safety orders = 2 AND datetime >= window start AND datetime <= window end AND close <= base entry price * (1 - safety order 3 deviation percent / 100)
Long: position side is long AND filled safety orders = 3 AND datetime >= window start AND datetime <= window end AND close <= base entry price * (1 - safety order 4 deviation percent / 100)
Long: position side is long AND filled safety orders = 4 AND datetime >= window start AND datetime <= window end AND close <= base entry price * (1 - safety order 5 deviation percent / 100)
Exit: long, close >= average entry price * (1 + take profit percent / 100)