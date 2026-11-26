Calculation: deviation_price(base_price, deviation) = base_price * (1 - deviation / 100)
Long: position side is flat AND RSI(close, rsi_length, T1, last completed bar) < rsi_threshold AND close < price_ceiling
Long: position side is long AND safety orders filled = 0 AND close <= deviation_price(base entry price, ao1_deviation)
Long: position side is long AND safety orders filled = 1 AND close <= deviation_price(base entry price, ao2_deviation)
Long: position side is long AND safety orders filled = 2 AND close <= deviation_price(base entry price, ao3_deviation)
Long: position side is long AND safety orders filled = 3 AND close <= deviation_price(base entry price, ao4_deviation)
Exit: long, close >= average entry price * (1 + take_profit_percent / 100)