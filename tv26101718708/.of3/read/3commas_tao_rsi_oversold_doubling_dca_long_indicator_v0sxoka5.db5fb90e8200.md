Calculation: AvgEntry = (base size + SUM over filled safety orders k of size_k) / (base size / entry price + SUM over filled safety orders k of size_k / fill close_k)
Long: datetime >= window start AND datetime <= window end AND position side is flat AND RSI(close, rsi length, T1, last completed bar) < rsi level
Long: datetime >= window start AND datetime <= window end AND close <= entry price * (1 - dev_1 / 100)
Long: datetime >= window start AND datetime <= window end AND close <= entry price * (1 - dev_2 / 100)
Long: datetime >= window start AND datetime <= window end AND close <= entry price * (1 - dev_3 / 100)
Long: datetime >= window start AND datetime <= window end AND close <= entry price * (1 - dev_4 / 100)
Long: datetime >= window start AND datetime <= window end AND close <= entry price * (1 - dev_5 / 100)
Exit: long, datetime >= window start AND datetime <= window end AND close >= AvgEntry * (1 + tp / 100)