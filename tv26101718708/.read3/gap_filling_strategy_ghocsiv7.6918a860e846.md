Calculation: new T1 bar = on chart bars, the current/forming T1 bar time changes
Calculation: up gap = on chart bars, open > high[1] AND min(open, close) > max(open[1], close[1])
Calculation: down gap = on chart bars, open < low[1] AND min(open[1], close[1]) > max(open, close)
Calculation: gap level = on chart bars, valuewhen(new T1 bar AND (up gap OR down gap), up gap ? max(open[1], close[1]) : min(open[1], close[1]), 0)
Long: (gap mode is exhaustion AND new T1 bar AND down gap) OR (gap mode is runaway/breakaway AND new T1 bar AND up gap)
Short: (gap mode is exhaustion AND new T1 bar AND up gap) OR (gap mode is runaway/breakaway AND new T1 bar AND down gap)
Exit: long, (gap mode is exhaustion AND high >= gap level) OR (gap mode is runaway/breakaway AND low <= gap level) OR (close policy is new session AND new T1 bar) OR (close policy is new gap AND new T1 bar AND (up gap OR down gap))
Exit: short, (gap mode is exhaustion AND low <= gap level) OR (gap mode is runaway/breakaway AND high >= gap level) OR (close policy is new session AND new T1 bar) OR (close policy is new gap AND new T1 bar AND (up gap OR down gap))