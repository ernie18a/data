Calculation: Breached(instrument, level, side) = on any bar since level was set, the instrument's low is below level for the low side or its high is above level for the high side
Calculation: Divergent(reference, side) = (Breached(primary) OR Breached(sister 1) OR Breached(sister 2)) AND NOT (Breached(primary) AND Breached(sister 1) AND Breached(sister 2)); primary is the chart instrument; primary level is its extreme in the side direction over the reference period or its pivot value; each sister level is that sister's extreme over the same period or its value at the pivot bar; reference is a completed session of a session window, a completed T1, T2 or T3 bar, or a confirmed pivot; breaches are checked on chart bars, except higher-timeframe references use last completed T4 bar values; sister 2 terms are false when sister 2 is excluded
Calculation: Gate passes(side) = gate filter is disabled OR (side gate series is at or above gate level AND no-trade series is below no-trade level AND bias tier series is at or above bias level), where the side gate series is the long gate series for long and the short gate series for short
Calculation: Pair confirmed(reference, side) = Breached(primary) AND Breached(diverging sister), where the diverging sister is sister 1 if its breach differed from the primary's when the reference was signaled, otherwise sister 2
Calculation: Entry(reference, side) = Divergent(reference, side) AND Gate passes(side) AND NOT Signaled(reference, side)[1]; for cycle references (T1, T2, T3 bars) the bar must also be inside the cycle window
Calculation: Signaled(reference, side) = NOT (bar at daily reset time) AND (Entry(reference, side) OR (Signaled(reference, side)[1] AND NOT Pair confirmed(reference, side)))
Calculation: Tier signal(tier, side) = some reference of the tier is Signaled(reference, side); T1 bars, T2 bars and T3 bars are aggregated from chart bars on a grid anchored to the cycle anchor time, with T1 longer than T2 longer than T3
Calculation: Composite long = Tier signal(session, long) AND Tier signal(T1 bars, long) AND (Tier signal(T2 bars, long) OR Tier signal(T3 bars, long))
Calculation: Composite short = Tier signal(session, short) AND Tier signal(T1 bars, short) AND (Tier signal(T2 bars, short) OR Tier signal(T3 bars, short))
Calculation: Higher-timeframe divergent(T4, side) = Divergent(last confirmed pivot of T4 bars, which is the pivot low for the low side or the pivot high for the high side, side), where pivots use the pivot lookback and breaches use last completed T4 bar values (chart bars when T4 is the chart timeframe), defined for each enabled higher timeframe T4 and for the chart timeframe when it is a higher timeframe
Long: Entry(last completed session of session window 1, low side) OR Entry(last completed session of session window 2, low side) OR Entry(last completed session of session window 3, low side)
Long: Entry(any of the most recent completed T1 bars within the T1 lookback depth, low side)
Long: Entry(any of the most recent completed T2 bars within the T2 lookback depth, low side)
Long: Entry(any of the most recent completed T3 bars within the T3 lookback depth, low side)
Long: Higher-timeframe divergent(T4, low side) AND NOT Higher-timeframe divergent(T4, low side)[1]
Short: Entry(last completed session of session window 1, high side) OR Entry(last completed session of session window 2, high side) OR Entry(last completed session of session window 3, high side)
Short: Entry(any of the most recent completed T1 bars within the T1 lookback depth, high side)
Short: Entry(any of the most recent completed T2 bars within the T2 lookback depth, high side)
Short: Entry(any of the most recent completed T3 bars within the T3 lookback depth, high side)
Short: Higher-timeframe divergent(T4, high side) AND NOT Higher-timeframe divergent(T4, high side)[1]
Long: Composite long AND NOT Composite long[1]
Short: Composite short AND NOT Composite short[1]
Exit: long, Signaled(reference, low side)[1] AND (Pair confirmed(reference, low side) OR bar at daily reset time), where reference is any session or cycle reference
Exit: short, Signaled(reference, high side)[1] AND (Pair confirmed(reference, high side) OR bar at daily reset time), where reference is any session or cycle reference
Exit: long, Higher-timeframe divergent(T4, low side)[1] AND NOT Higher-timeframe divergent(T4, low side)
Exit: short, Higher-timeframe divergent(T4, high side)[1] AND NOT Higher-timeframe divergent(T4, high side)