Long: selected MA(short source, shorter lookback) crosses above selected MA(long source, longer lookback), using the same MA type and shared MA parameters
Short: selected MA(short source, shorter lookback) crosses below selected MA(long source, longer lookback), using the same MA type and shared MA parameters
Exit: long, take-profit percentage > 0 AND close >= entry price * (1 + take-profit percentage / 100)
Exit: long, stop-loss percentage > 0 AND close <= entry price * (1 - stop-loss percentage / 100)
Exit: short, take-profit percentage > 0 AND close <= entry price * (1 - take-profit percentage / 100)
Exit: short, stop-loss percentage > 0 AND close >= entry price * (1 + stop-loss percentage / 100)