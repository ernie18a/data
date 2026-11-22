Calculation: Deviation(n) = first averaging order deviation * sum over j from 0 to n-1 of (averaging order deviation step multiplier)^j
Calculation: AveragingOrderSize(j) = first averaging order size * (averaging order size multiplier)^(j-1)
Calculation: AverageEntry = (base order size + sum over j from 1 to F of AveragingOrderSize(j)) / (base order size / base entry price + sum over j from 1 to F of AveragingOrderSize(j) / close at fill j), where F = averaging orders filled since base entry
Calculation: Trough = lowest close among bars since base entry within the active period where close <= AverageEntry * (1 - take-profit percentage / 100); undefined if no such bar
Short: position side is flat AND datetime within active period AND RSI(close, RSI length) on T1 bars crosses below RSI cross level, using last completed T1 bar
Short: position side is short AND datetime within active period AND averaging orders filled since base entry < averaging order count AND close >= base entry price * (1 + Deviation(averaging orders filled since base entry + 1) / 100)
Exit: short, datetime within active period AND close >= AverageEntry * (1 + stop-loss percentage / 100)
Exit: short, datetime within active period AND Trough is defined AND close >= Trough * (1 + trailing percentage / 100)