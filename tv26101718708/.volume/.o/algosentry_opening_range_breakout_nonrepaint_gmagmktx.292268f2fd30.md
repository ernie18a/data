Calculation: Opening range high = highest high of the configured opening session, frozen when that session ends
Calculation: Opening range low = lowest low of the configured opening session, frozen when that session ends
Calculation: Range size = opening range high − opening range low
Calculation: Upper retest level = opening range high − range size × configured retest depth
Calculation: Lower retest level = opening range low + range size × configured retest depth
Calculation: Volume point of control = midpoint of the highest-volume price bin across the configured window, assigning each bar’s volume evenly to bins between its low and high; calculate once when the opening session ends and use only if inside the opening range
Long: After the opening range closes and within the configured tracking period, the first completed bar on the configured confirmation timeframe closes above the opening range high, and no earlier short break occurred unless both directions are allowed
Short: After the opening range closes and within the configured tracking period, the first completed bar on the configured confirmation timeframe closes below the opening range low, and no earlier long break occurred unless both directions are allowed
Long: After a long break, the first subsequent completed chart bar within the configured tracking period has low at or below any enabled retest zone: opening range high, upper retest level, or volume point of control
Short: After a short break, the first subsequent completed chart bar within the configured tracking period has high at or above any enabled retest zone: opening range low, lower retest level, or volume point of control
Long: After a long retest, the first subsequent completed chart bar within the configured tracking period closes above the opening range high
Short: After a short retest, the first subsequent completed chart bar within the configured tracking period closes below the opening range low