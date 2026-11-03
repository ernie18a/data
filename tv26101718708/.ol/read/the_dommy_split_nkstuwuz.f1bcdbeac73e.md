Calculation: Range high = highest high from bars in the daily 08:00–08:15 New York session
Calculation: Range low = lowest low from bars in the daily 08:00–08:15 New York session
Calculation: Range midpoint = (range high + range low) / 2
Calculation: Breakout direction = bullish after a close above range high; bearish after a close below range low; persists until an opposite breakout; reset each day
Long: datetime is within 09:45–11:00 New York AND range is locked AND breakout direction is bullish AND low <= range midpoint AND position is flat AND today's consecutive losing closed trades < 2
Short: datetime is within 09:45–11:00 New York AND range is locked AND breakout direction is bearish AND high >= range midpoint AND position is flat AND today's consecutive losing closed trades < 2
Exit: Long, low <= range low OR high >= entry + 2 × (entry − range low) OR high has previously reached entry + 2 × (entry − range low) AND low <= entry OR high >= entry + 4 × (entry − range low) OR datetime >= 11:00 New York
Exit: Short, high >= range high OR low <= entry − 2 × (range high − entry) OR low has previously reached entry − 2 × (range high − entry) AND high >= entry OR low <= entry − 4 × (range high − entry) OR datetime >= 11:00 New York