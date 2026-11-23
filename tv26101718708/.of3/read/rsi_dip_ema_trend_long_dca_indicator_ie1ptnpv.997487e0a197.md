Calculation: Average entry price = sum of fill margin / sum of (fill margin / fill price), summed over the base entry and each filled safety order, where base entry margin = base order margin, safety order k margin = first SO margin * SO size multiplier^(k - 1), and fill price = close of the fill bar
Calculation: Cumulative deviation(k) = first SO step * sum over j from 0 to k - 1 of SO step multiplier^j
Calculation: Highest close since entry = highest close from the entry bar through the current bar
Long: position side is flat AND RSI(close, RSI lookback, T1, last completed bar) crosses below RSI level AND EMA(close, shorter lookback, T2, last completed bar) > EMA(close, longer lookback, T2, last completed bar)
Long: position side is long AND number of filled safety orders < max SO count AND close <= entry price * (1 - Cumulative deviation(number of filled safety orders + 1))
Exit: long, close <= average entry price * (1 - stop loss %)
Exit: long, datetime - entry datetime >= max hold duration
Exit: long, highest close since entry >= average entry price * (1 + take-profit %) AND close <= highest close since entry * (1 - trailing deviation %)