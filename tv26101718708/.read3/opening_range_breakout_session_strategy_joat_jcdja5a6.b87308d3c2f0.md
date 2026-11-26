Calculation: InOpeningWindow = the bar's time is inside the opening window in the session time zone
Calculation: InTradeSession = the bar's time is inside the trade session window in the session time zone
Calculation: RangeLocked = the current bar is at or after the end of the opening window within the current T1 bar
Calculation: OpeningRangeHigh = highest high of the bars with InOpeningWindow true within the current T1 bar
Calculation: OpeningRangeLow = lowest low of the bars with InOpeningWindow true within the current T1 bar
Calculation: BreakoutMargin = ATR(high, low, close, ATR length) * breakout margin multiplier
Calculation: EntriesToday = number of Long or Short entries since the current T1 bar began
Calculation: BarsSinceEntry = bars since the last Long or Short entry, or infinity if none
Calculation: StopDistance = (if the ATR stop switch is on: ATR(high, low, close, ATR length) * stop multiplier; else: distance from the entry price to the opening range edge opposite the position side), evaluated on the entry bar
Long: close crosses above OpeningRangeHigh + BreakoutMargin AND InTradeSession AND RangeLocked AND EntriesToday < max trades per day AND BarsSinceEntry >= minimum bars between entries
Short: close crosses below OpeningRangeLow - BreakoutMargin AND InTradeSession AND RangeLocked AND EntriesToday < max trades per day AND BarsSinceEntry >= minimum bars between entries
Long: RangeLocked AND close > OpeningRangeHigh
Short: RangeLocked AND close < OpeningRangeLow
Exit: Long, low <= entry price - StopDistance OR high >= entry price + StopDistance * TP1 multiple OR (close crosses above OpeningRangeHigh + BreakoutMargin AND InTradeSession AND RangeLocked AND EntriesToday < max trades per day AND BarsSinceEntry >= minimum bars between entries)
Exit: Short, high >= entry price + StopDistance OR low <= entry price - StopDistance * TP1 multiple OR (close crosses below OpeningRangeLow - BreakoutMargin AND InTradeSession AND RangeLocked AND EntriesToday < max trades per day AND BarsSinceEntry >= minimum bars between entries)