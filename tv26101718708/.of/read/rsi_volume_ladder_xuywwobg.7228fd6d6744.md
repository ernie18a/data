Calculation: Take-profit price = average entry price × (1 + take-profit percentage)
Calculation: Stop-loss price = lowest entry price × (1 − stop-loss percentage)
Long: RSI < oversold threshold AND volume > volume SMA × volume multiplier AND (no previous fill in the current position OR close < last fill price × (1 − minimum drop percentage)) AND open long entries < maximum positions AND (no prior exit OR bars since prior exit > cooldown for that exit type)
Exit: Long, high ≥ take-profit price OR low ≤ stop-loss price