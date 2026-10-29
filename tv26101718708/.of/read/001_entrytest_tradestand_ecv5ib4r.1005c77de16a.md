Long: trade mode = “new buy” AND datetime >= configured execution time AND position count = 0
Long: trade mode = “close sell” AND this is the first bar where time[1] != time AND position count = 0
Short: trade mode = “new sell” AND datetime >= configured execution time AND position count = 0
Short: trade mode = “close buy” AND this is the first bar where time[1] != time AND position count = 0
Exit: long, trade mode = “close sell” AND datetime >= configured execution time
Exit: short, trade mode = “close buy” AND datetime >= configured execution time