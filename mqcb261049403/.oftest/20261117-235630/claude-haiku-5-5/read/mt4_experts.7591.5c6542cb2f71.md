Calculation: LONG_LEVEL = PivotPoint(T1, last completed bar) + metric * point
Calculation: SHORT_LEVEL = PivotPoint(T1, last completed bar) - metric * point
Calculation: LONG_TARGET = MAX(close(T1, last completed bar) + range factor * (high(T1, last completed bar) - low(T1, last completed bar)), PivotPoint(T1, last completed bar) - 2 * metric * point - target offset * point)
Calculation: SHORT_TARGET = MIN(close(T1, last completed bar) - range factor * (high(T1, last completed bar) - low(T1, last completed bar)), PivotPoint(T1, last completed bar) - 2 * metric * point - target offset * point)
Calculation: HIGHEST_CLOSE = Highest(close) since entry
Calculation: LOWEST_CLOSE = Lowest(close) since entry
Long: close crosses above LONG_LEVEL AND hour(datetime) >= start hour AND hour(datetime) <= end hour AND position side is flat
Short: close crosses below SHORT_LEVEL AND hour(datetime) >= start hour AND hour(datetime) <= end hour AND position side is flat
Exit: long, hour(datetime) < start hour OR hour(datetime) > end hour
Exit: short, hour(datetime) < start hour OR hour(datetime) > end hour
Exit: long, low <= SHORT_LEVEL at entry AND entry price >= HIGHEST_CLOSE - trail * point
Exit: long, low <= HIGHEST_CLOSE - trail * point AND entry price < HIGHEST_CLOSE - trail * point
Exit: long, high >= LONG_TARGET at entry
Exit: short, high >= LONG_LEVEL at entry AND entry price <= LOWEST_CLOSE + trail * point
Exit: short, high >= LOWEST_CLOSE + trail * point AND entry price > LOWEST_CLOSE + trail * point
Exit: short, low <= SHORT_TARGET at entry