Calculation: in active window = window filter off OR (datetime >= window start AND datetime <= window end)
Calculation: ladder deviation(k) = first AO deviation * sum for j from 0 to k-1 of deviation step multiplier^j
Calculation: lowest take-profit close = minimum of close over bars since position opened where close <= average entry price * (1 - take-profit percent/100)
Short: RSI(close, RSI length, T1, last completed bar) crosses below RSI level on T1 bars AND position side is flat AND in active window
Short: position side is short AND averaging fills so far < averaging order count AND close >= base entry price * (1 + ladder deviation(averaging fills so far + 1) / 100) AND in active window
Exit: short, close >= average entry price * (1 + stop-loss percent/100) AND in active window
Exit: short, close >= lowest take-profit close * (1 + trailing percent/100) AND in active window