Calculation: New low = current low is below the lowest low over a prior-bar lookback
Calculation: Rally low = low of the latest new-low bar; reset to the current low when an active Day-1 low is undercut
Calculation: Day 1 = rally attempt is inactive, a rally low exists, and current low is at least the rally low; a new-low bar can qualify after updating the rally low
Calculation: Rally attempt active = set on Day 1; cleared by a new low or an active Day-1 low undercut
Calculation: Day-1 low = current low on Day 1; cleared when the rally attempt is cleared
Calculation: Bars since Day 1 = number of chart bars since Day 1, with Day 1 equal to zero
Calculation: FTD found = cleared by a new low, Day 1, or a Day-1 low undercut; set after an FTD
Long: Day 1 OR (rally attempt active AND FTD not found AND bars since Day 1 >= 3 AND ((close / previous close) - 1) * 100 >= minimum gain threshold AND volume > previous volume AND low >= Day-1 low)