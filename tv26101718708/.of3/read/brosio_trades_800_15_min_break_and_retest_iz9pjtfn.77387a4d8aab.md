Calculation: range high = maximum high of chart bars in the configured range session, held fixed after that session ends
Calculation: range low = minimum low of chart bars in the configured range session, held fixed after that session ends
Calculation: range midpoint = (range high + range low) / 2
Calculation: breakout side = bullish after a close above the completed range high, bearish after a close below the completed range low, otherwise unchanged
Long: range complete AND close > range high
Short: range complete AND close < range low
Long: range complete AND breakout side is bullish AND low <= range midpoint AND during the configured trade session AND no entry has occurred since the current date began AND no position is open
Short: range complete AND breakout side is bearish AND high >= range midpoint AND during the configured trade session AND no entry has occurred since the current date began AND no position is open
Exit: Long, low <= range low
Exit: Long, high >= entry + first-target multiple × (entry − range low)
Exit: Long, high >= entry + runner-target multiple × (entry − range low)
Exit: Long, first target has been reached since entry AND low <= entry
Exit: Short, high >= range high
Exit: Short, low <= entry − first-target multiple × (range high − entry)
Exit: Short, low <= entry − runner-target multiple × (range high − entry)
Exit: Short, first target has been reached since entry AND high >= entry
Exit: Long, the configured trade session has just ended
Exit: Short, the configured trade session has just ended