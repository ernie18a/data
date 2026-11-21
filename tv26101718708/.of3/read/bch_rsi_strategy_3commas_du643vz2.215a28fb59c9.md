Calculation: cumulative AO deviation(k) = first AO deviation * sum over i from 0 to k-1 of AO deviation multiplier^i
Calculation: armed low = running minimum of close over bars in the position where close <= average entry price * (1 - take-profit percent / 100), through the current bar
Short: position side is flat AND (window limit switch is off OR (datetime >= window start AND datetime <= window end)) AND RSI(close, RSI length, T1, last completed bar) crosses under RSI level, evaluated on T1 bars
Short: position side is short AND AOs placed < AO count AND close >= base entry price * (1 + cumulative AO deviation(AOs placed + 1) / 100) AND (window limit switch is off OR (datetime >= window start AND datetime <= window end))
Exit: short, close >= average entry price * (1 + stop-loss percent / 100)
Exit: short, armed low exists AND close >= armed low * (1 + trailing percent / 100)