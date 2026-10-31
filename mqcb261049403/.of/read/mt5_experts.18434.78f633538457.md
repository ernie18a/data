Calculation: Derived price = x - (high + low) / 2, where x = (high + low + close + low) / 2 if close < open, (high + low + close + high) / 2 if close > open, and (high + low + 2 * close) / 2 if close = open; use close if the derived price is zero.
Calculation: Smoothed price = a selectable moving average of derived price.
Calculation: Trading interval = when start hour < end hour: (hour = start hour AND minute >= start minute) OR (hour > start hour AND hour < end hour) OR (hour = end hour AND minute < end minute); when start hour = end hour: hour = start hour AND minute >= start minute AND minute < end minute; when start hour > end hour: (hour >= start hour AND minute >= start minute) OR hour < end hour OR (hour = end hour AND minute < end minute).
Long: chart-timeframe smoothed price > previous chart-timeframe smoothed price.
Short: chart-timeframe smoothed price < previous chart-timeframe smoothed price.
Long: selected higher- or lower-timeframe smoothed price > its previous value AND its previous value <= its value two bars earlier AND (trading interval filter disabled OR datetime is within trading interval); use the selected signal bar, either the last completed bar or the bar still forming.
Short: selected higher- or lower-timeframe smoothed price < its previous value AND its previous value >= its value two bars earlier AND (trading interval filter disabled OR datetime is within trading interval); use the selected signal bar, either the last completed bar or the bar still forming.
Exit: long, selected higher- or lower-timeframe smoothed price < its previous value; use the selected signal bar, either the last completed bar or the bar still forming.
Exit: short, selected higher- or lower-timeframe smoothed price > its previous value; use the selected signal bar, either the last completed bar or the bar still forming.
Exit: long, trading interval filter enabled AND datetime is outside trading interval.
Exit: short, trading interval filter enabled AND datetime is outside trading interval.
Exit: long, stop loss enabled AND low <= entry price - stop distance OR take profit enabled AND high >= entry price + profit distance.
Exit: short, stop loss enabled AND high >= entry price + stop distance OR take profit enabled AND low <= entry price - profit distance.