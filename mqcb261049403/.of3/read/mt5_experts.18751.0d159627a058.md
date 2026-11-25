Long: open long position count = 0 OR close < MIN(long entry prices)
Short: open long position count > 0 AND close >= MIN(long entry prices) AND close > 0 AND (open short position count = 0 OR close > MAX(short entry prices))
Exit: long, open long position count > 1 AND open short position count > 1
Exit: short, open long position count > 1 AND open short position count > 1