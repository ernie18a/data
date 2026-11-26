Calculation: AO trigger deviation(k) = first AO deviation * sum for j = 0 to k-1 of (AO deviation step multiplier)^j
Calculation: AO fill size(k) = first AO size * (AO size multiplier)^(k-1)
Calculation: average entry price = (base order size + sum for j = 1 to AO fills so far of AO fill size(j)) / (base order size / entry price + sum for j = 1 to AO fills so far of AO fill size(j) / close at AO j fill bar)
Calculation: TP trough = lowest close over bars of the current position where close <= average entry price * (1 - TP percent / 100), or none if there is no such bar
Short: position side is flat AND RSI(close, RSI length, T1, last completed bar) crosses below RSI crossing level AND (date filter off OR datetime in date window)
Short: position side is short AND AO fills so far < AO count AND close >= entry price * (1 + AO trigger deviation(AO fills so far + 1) / 100) AND (date filter off OR datetime in date window)
Exit: short, close >= average entry price * (1 + stop loss percent / 100) AND (date filter off OR datetime in date window)
Exit: short, TP trough is defined AND close >= TP trough * (1 + trailing percent / 100) AND (date filter off OR datetime in date window)