Calculation: AvgEntry = (entry size + sum over filled safety orders k of safety order k size) / (entry size / entry price + sum over filled safety orders k of safety order k size / fill price k)
Long: position side is flat AND datetime >= window start AND datetime <= window end AND RSI(close, RSI length, T1, last completed bar) < RSI threshold AND close < price ceiling
Long: position side is long AND datetime >= window start AND datetime <= window end AND close <= entry price * (1 - safety order 1 deviation)
Long: position side is long AND datetime >= window start AND datetime <= window end AND close <= entry price * (1 - safety order 2 deviation)
Long: position side is long AND datetime >= window start AND datetime <= window end AND close <= entry price * (1 - safety order 3 deviation)
Long: position side is long AND datetime >= window start AND datetime <= window end AND close <= entry price * (1 - safety order 4 deviation)
Exit: long, datetime >= window start AND datetime <= window end AND close >= AvgEntry * (1 + take profit)