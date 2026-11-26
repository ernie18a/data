Calculation: BreakPrice(side) = close if break source is close, else high for upper or low for lower
Calculation: Pivot(side) = PivotHigh(high, pivot length, pivot length) for upper or PivotLow(low, pivot length, pivot length) for lower, when a pivot is confirmed on this bar; its pivot bar is pivot length bars earlier
Calculation: Broken(side) = levels of that side in LiveLevels[1] where BreakPrice(side) > level + ATR(atr length) * break buffer for upper, or BreakPrice(side) < level - ATR(atr length) * break buffer for lower
Calculation: Remaining(side) = levels of that side in LiveLevels[1] not in Broken(side) whose age in bars since creation is below max age on this bar
Calculation: Partner(side) = the nearest unpaired pivot of that side in Unpaired(side)[1] where abs(Pivot(side) - unpaired price) <= match % * unpaired price and the pivot bar is at least gap bars after the unpaired pivot's bar, if any
Calculation: Created(side) = a new level of that side priced max(Pivot(side), Partner(side)) for upper or min(Pivot(side), Partner(side)) for lower, when Pivot(side) is confirmed, Partner(side) exists, and Pivot(side) is not within match % of the price of any level in Remaining(side)
Calculation: Unpaired(side) = Unpaired(side)[1] minus Partner(side) when Created(side) exists, plus Pivot(side) when Pivot(side) is confirmed, Partner(side) does not exist, and Pivot(side) is not within match % of the price of any level in Remaining(side); keep only the newest unpaired capacity entries of that side
Calculation: LiveLevels = Remaining(upper) + Remaining(lower) + Created(upper) + Created(lower), with the oldest levels removed while the count exceeds live capacity
Calculation: DeadLevels = DeadLevels[1] + Broken(upper) + Broken(lower), keeping only the newest dead capacity levels
Long: BreakPrice(upper) > level + ATR(atr length) * break buffer, for some upper level in LiveLevels[1]
Short: BreakPrice(lower) < level - ATR(atr length) * break buffer, for some lower level in LiveLevels[1]
Long: low <= level AND close > level, for some upper level in DeadLevels broken on an earlier bar where no bar after its break bar and before this bar had low <= level AND close > level
Short: high >= level AND close < level, for some lower level in DeadLevels broken on an earlier bar where no bar after its break bar and before this bar had high >= level AND close < level