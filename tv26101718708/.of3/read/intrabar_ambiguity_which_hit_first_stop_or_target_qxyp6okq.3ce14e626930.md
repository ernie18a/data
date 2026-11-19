Long: confirmed bar AND flat AND ATR(length) > 0
Short: confirmed bar AND flat AND ATR(length) > 0
Exit: long, after entry bar AND (low <= entry price - stop distance * ATR(length, entry bar) OR high >= entry price + target distance * ATR(length, entry bar) OR bars since entry >= holding period)
Exit: short, after entry bar AND (high >= entry price + stop distance * ATR(length, entry bar) OR low <= entry price - target distance * ATR(length, entry bar) OR bars since entry >= holding period)