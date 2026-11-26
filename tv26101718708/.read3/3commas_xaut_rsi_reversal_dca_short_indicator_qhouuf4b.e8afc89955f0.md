Calculation: in period = period filter disabled OR (datetime >= period start AND datetime <= period end)
Calculation: filled AOs = number of averaging orders filled since entry
Calculation: AO deviation(k) = sum over j = 1..k of (first AO deviation * deviation step multiplier^(j-1)), in percent
Calculation: average entry = (base order size + sum over j = 1..filled AOs of AO size(j)) / (base order size / entry price + sum over j = 1..filled AOs of AO size(j) / close at AO fill j), where AO size(j) = first AO size * AO size multiplier^(j-1)
Calculation: trough = lowest close since entry among bars where close <= average entry * (1 - take-profit/100), undefined if no such bar
Short: position side is flat AND in period AND RSI(close, RSI length, T1, last completed bar) crosses below trigger level, evaluated on T1 bars
Short: position side is short AND filled AOs < averaging order count AND in period AND close >= entry price * (1 + AO deviation(filled AOs + 1)/100)
Exit: short, in period AND close >= average entry * (1 + stop loss/100)
Exit: short, in period AND close >= trough * (1 + trailing retrace/100)