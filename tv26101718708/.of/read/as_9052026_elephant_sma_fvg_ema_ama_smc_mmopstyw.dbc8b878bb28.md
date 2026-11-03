Calculation: Confirmed swing high or low = a pivot high or low confirmed after an equal number of preceding and subsequent chart bars; if both are confirmed on the same bar, process only the swing high.
Calculation: Supply and demand zones = at each confirmed swing high or low, respectively, propose a zone extending from the pivot toward lower or higher prices by a parameter times the current ATR. Accept it only if its midpoint is outside the inclusive interval of each active same-side zone's midpoint plus or minus a parameter times the current ATR. Keep a parameterized number of the most recently accepted zones on each side, discarding the oldest when necessary. Remove a supply zone when close reaches or exceeds its upper edge; remove a demand zone when close reaches or falls below its lower edge. Create zones before checking for removals on each bar.
Long: Close > SMA of close.
Short: Close < SMA of close.
Long: High - low > ATR times a parameter AND high > low AND absolute value of close - open divided by high - low > a parameter AND close > open.
Short: High - low > ATR times a parameter AND high > low AND absolute value of close - open divided by high - low > a parameter AND close < open.
Long: Low > high two bars earlier.
Short: High < low two bars earlier.
Long: A swing high is confirmed AND its value >= the previous confirmed swing high, initially zero.
Short: A swing high is confirmed AND its value < the previous confirmed swing high, initially zero.
Long: A swing low is confirmed AND its value >= the previous processed swing low, initially zero.
Short: A swing low is confirmed AND its value < the previous processed swing low, initially zero.
Long: A demand zone is accepted.
Short: A supply zone is accepted.
Long: Close >= the upper edge of an active supply zone.
Short: Close <= the lower edge of an active demand zone.