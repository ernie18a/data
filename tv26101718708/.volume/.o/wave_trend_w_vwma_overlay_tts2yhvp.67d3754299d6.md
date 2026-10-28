Calculation: Wave Trend 1 = EMA(CI, average length), where CI = (HLC3 − EMA(HLC3, channel length)) / (0.015 × EMA(abs(HLC3 − EMA(HLC3, channel length)), channel length))
Calculation: Wave Trend 2 = SMA(Wave Trend 1, 4)
Long: Wave Trend 1 crosses above Wave Trend 2 AND (session limiting is disabled OR current bar time is within Session 1 or Session 2: (hour = start hour AND minute ≥ start minute) OR (hour > start hour AND hour < stop hour) OR (hour = stop hour AND minute < stop minute))
Short: Wave Trend 1 crosses below Wave Trend 2 AND (session limiting is disabled OR current bar time is within Session 1 or Session 2: (hour = start hour AND minute ≥ start minute) OR (hour > start hour AND hour < stop hour) OR (hour = stop hour AND minute < stop minute))
Exit: long, Session 1 close-all is enabled AND hour = Session 1 stop hour AND minute ≥ Session 1 stop minute
Exit: short, Session 1 close-all is enabled AND hour = Session 1 stop hour AND minute ≥ Session 1 stop minute
Exit: long, Session 2 close-all is enabled AND hour = Session 2 stop hour AND minute ≥ Session 2 stop minute
Exit: short, Session 2 close-all is enabled AND hour = Session 2 stop hour AND minute ≥ Session 2 stop minute