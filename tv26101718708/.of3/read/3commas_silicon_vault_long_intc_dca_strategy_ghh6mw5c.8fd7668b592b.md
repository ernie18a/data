Calculation: AverageEntry = sum(fill price * fill quantity) / sum(fill quantity), over fills since position opened
Calculation: SafetyTrigger(n) = base order price * (1 - sum over i=1..n of first safety step * step coefficient^(i-1) / 100)
Long: position side = flat AND datetime >= window start AND datetime <= window end
Long: position side = long AND filled safety orders < maximum safety orders AND low <= SafetyTrigger(filled safety orders + 1)
Exit: long, RSI(close, RSI length, T1, last completed bar) crosses above RSI threshold AND close >= AverageEntry * (1 + minimum profit / 100)
Exit: long, RSI gate disabled AND close >= AverageEntry * (1 + minimum profit / 100)