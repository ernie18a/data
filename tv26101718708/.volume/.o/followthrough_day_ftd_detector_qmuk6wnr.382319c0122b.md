Calculation: New low = current daily low < lowest low of the preceding lookback of completed daily bars
Calculation: Day 1 = no active rally attempt and a new low exists and current daily low ≥ the latest rally low; a new low sets the latest rally low to the current daily low before this check
Calculation: Active rally attempt = Day 1 has occurred and its low has not been undercut; reset on a new low or an undercut
Calculation: FTD already found = an FTD condition was met in the current rally attempt; reset on a new low or an undercut
Calculation: Days since Day 1 = current daily bar index − Day 1 bar index
Calculation: Daily close gain = (current daily close / prior completed daily close − 1) × 100
Long: Day 1 OR (active rally attempt AND FTD not already found AND days since Day 1 ≥ minimum wait AND daily close gain ≥ minimum gain AND current daily volume > prior completed daily volume AND current daily low ≥ Day 1 low)