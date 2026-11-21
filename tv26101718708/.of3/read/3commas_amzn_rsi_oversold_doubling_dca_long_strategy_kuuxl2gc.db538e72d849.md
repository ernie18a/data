Calculation: safety orders filled = count of safety-order fills in the current position
Long: position side is flat AND RSI(close, RSI length, T1, last completed bar) < RSI threshold AND datetime >= window start AND datetime <= window end
Long: position side is long AND safety orders filled = 0 AND close <= base entry price * (1 - deviation_1 / 100) AND datetime >= window start AND datetime <= window end
Long: position side is long AND safety orders filled = 1 AND close <= base entry price * (1 - deviation_2 / 100) AND datetime >= window start AND datetime <= window end
Long: position side is long AND safety orders filled = 2 AND close <= base entry price * (1 - deviation_3 / 100) AND datetime >= window start AND datetime <= window end
Long: position side is long AND safety orders filled = 3 AND close <= base entry price * (1 - deviation_4 / 100) AND datetime >= window start AND datetime <= window end
Long: position side is long AND safety orders filled = 4 AND close <= base entry price * (1 - deviation_5 / 100) AND datetime >= window start AND datetime <= window end
Exit: long, close >= average entry price * (1 + take profit / 100)