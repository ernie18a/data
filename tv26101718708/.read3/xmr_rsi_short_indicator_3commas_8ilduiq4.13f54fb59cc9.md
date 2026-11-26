Calculation: AO deviation(k) = first AO deviation * SUM over i from 0 to k-1 of deviation step multiplier^i
Calculation: AO size(k) = first AO size * AO size multiplier^(k-1)
Calculation: average entry = (base order size + SUM over i from 1 to AO fills since entry of AO size(i)) / (base order size / entry price + SUM over i from 1 to AO fills since entry of AO size(i) / close at AO fill i)
Calculation: take-profit low = running minimum of close since entry over bars where (active window disabled OR (datetime >= window start AND datetime <= window end)) AND close <= average entry * (1 - take-profit percent / 100)
Short: position side = flat AND (active window disabled OR (datetime >= window start AND datetime <= window end)) AND RSI(close, RSI length, T1, last completed bar) crosses below RSI level
Short: position side = short AND (active window disabled OR (datetime >= window start AND datetime <= window end)) AND AO fills since entry < AO count AND close >= entry price * (1 + AO deviation(AO fills since entry + 1) / 100)
Exit: short, (active window disabled OR (datetime >= window start AND datetime <= window end)) AND close >= average entry * (1 + stop loss percent / 100)
Exit: short, (active window disabled OR (datetime >= window start AND datetime <= window end)) AND close >= take-profit low * (1 + trailing percent / 100)