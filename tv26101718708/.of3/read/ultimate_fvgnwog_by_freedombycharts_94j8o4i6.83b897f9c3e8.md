Calculation: NewBar(T) = last completed T bar's time on this chart bar != its time on the previous chart bar
Calculation: Mid = (top + bottom) / 2
Calculation: BullMitPx = low under wick mitigation methods or min(open, close) under body mitigation methods (chart bar values)
Calculation: BearMitPx = high under wick mitigation methods or max(open, close) under body mitigation methods (chart bar values)
Calculation: BullMitLvl = bottom under full mitigation methods or Mid under midpoint mitigation methods
Calculation: BearMitLvl = top under full mitigation methods or Mid under midpoint mitigation methods
Long: high[2] < low
Short: low[2] > high
Short: first bar at or after creation of a bull chart FVG where BullMitPx <= BullMitLvl, with top = low and bottom = high[2] at creation
Long: first bar at or after creation of a bear chart FVG where BearMitPx >= BearMitLvl, with top = low[2] and bottom = high at creation
Long: NewBar(T1) AND T1 high[2] < T1 low[0], using last completed T1 bars
Short: NewBar(T1) AND T1 low[2] > T1 high[0], using last completed T1 bars
Long: first bar at or after creation of a bull T1 FVG where low <= top, with top = T1 low[0] at creation
Short: first bar at or after creation of a bear T1 FVG where high >= bottom, with bottom = T1 high[0] at creation
Short: first bar at or after creation of a bull T1 FVG where BullMitPx <= BullMitLvl, with top = T1 low[0] and bottom = T1 high[2] at creation
Long: first bar at or after creation of a bear T1 FVG where BearMitPx >= BearMitLvl, with top = T1 low[2] and bottom = T1 high[0] at creation
Long: NewBar(T2) AND T2 high[2] < T2 low[0], using last completed T2 bars
Short: NewBar(T2) AND T2 low[2] > T2 high[0], using last completed T2 bars
Long: first bar at or after creation of a bull T2 FVG where low <= top, with top = T2 low[0] at creation
Short: first bar at or after creation of a bear T2 FVG where high >= bottom, with bottom = T2 high[0] at creation
Short: first bar at or after creation of a bull T2 FVG where BullMitPx <= BullMitLvl, with top = T2 low[0] and bottom = T2 high[2] at creation
Long: first bar at or after creation of a bear T2 FVG where BearMitPx >= BearMitLvl, with top = T2 low[2] and bottom = T2 high[0] at creation
Long: NewBar(T3) AND T3 high[2] < T3 low[0], using last completed T3 bars
Short: NewBar(T3) AND T3 low[2] > T3 high[0], using last completed T3 bars
Long: first bar at or after creation of a bull T3 FVG where low <= top, with top = T3 low[0] at creation
Short: first bar at or after creation of a bear T3 FVG where high >= bottom, with bottom = T3 high[0] at creation
Short: first bar at or after creation of a bull T3 FVG where BullMitPx <= BullMitLvl, with top = T3 low[0] and bottom = T3 high[2] at creation
Long: first bar at or after creation of a bear T3 FVG where BearMitPx >= BearMitLvl, with top = T3 low[2] and bottom = T3 high[0] at creation
Long: bar time in session time zone equals reopen time AND open > close[1]
Short: bar time in session time zone equals reopen time AND open < close[1]