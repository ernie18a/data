Calculation: LadderDeviation(k) = sum over i from 1 to k of (first averaging-order deviation * deviation step multiplier^(i-1))
Calculation: TrailMin = minimum of close over bars since position opened where close <= average entry price * (1 - take-profit percent / 100), undefined if no such bar
Short: position side is flat AND datetime >= window start AND datetime <= window end AND RSI(close, RSI length, T1, last completed bar) crosses below RSI cross level, with the crossing evaluated on T1 bars and taken by chart bars
Short: position side is short AND datetime >= window start AND datetime <= window end AND averaging orders placed in trade < averaging-order count AND close >= entry price * (1 + LadderDeviation(averaging orders placed in trade + 1) / 100)
Exit: short, close >= average entry price * (1 + stop-loss percent / 100)
Exit: short, TrailMin is defined AND close >= TrailMin * (1 + trailing percent / 100)