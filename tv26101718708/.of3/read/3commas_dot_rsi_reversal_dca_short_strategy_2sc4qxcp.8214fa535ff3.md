Calculation: deviation(k) = sum for j from 1 to k of first deviation * deviation multiplier^(j - 1)
Calculation: averaging order count = number of averaging short orders placed in the current position
Calculation: trough = lowest close among bars in the current position where close <= average entry price * (1 - take-profit percent / 100)
Short: RSI(close, RSI lookback, T1, last completed bar) crosses under RSI level AND position side is flat AND datetime >= window start AND datetime <= window end
Short: position side is short AND averaging order count < maximum averaging orders AND close >= base entry price * (1 + deviation(averaging order count + 1) / 100) AND datetime >= window start AND datetime <= window end
Exit: short, close >= average entry price * (1 + stop-loss percent / 100)
Exit: short, trough is defined AND close >= trough * (1 + trailing percent / 100)