Calculation: BullishFVG(bars) = low > high[2] AND close[1] > open[1]
Calculation: BearishFVG(bars) = high < low[2] AND close[1] < open[1]
Calculation: AlternatingPivots = alternating sequence of PivotHigh(high, left bars, right bars) and PivotLow(low, left bars, right bars) values on chart bars, where a pivot of the same type as the latest element replaces it if more extreme and is otherwise dropped, and a pivot of the other type is appended
Calculation: BullTarget = max(high, high[1]) of T1 bars, evaluated at the most recent chart bar where BullishFVG(T1, last completed bar) holds
Calculation: BearTarget = min(low, low[1]) of T1 bars, evaluated at the most recent chart bar where BearishFVG(T1, last completed bar) holds
Calculation: BullTapped = BullishFVG(T1, last completed bar) AND, since the current T1 bar opened, low(T1, bar still forming) <= low(T1, last completed bar) occurred on an earlier chart bar than high(T1, bar still forming) >= BullTarget
Calculation: BearTapped = BearishFVG(T1, last completed bar) AND, since the current T1 bar opened, high(T1, bar still forming) >= high(T1, last completed bar) occurred on an earlier chart bar than low(T1, bar still forming) <= BearTarget
Long: BullTapped AND NOT BullTapped[1]
Long: first bar at or after BullTapped becomes true where BullishFVG(chart bars) holds
Long: first bar at or after BullTapped becomes true where close > low[2] evaluated at the latest chart bar where BearishFVG(chart bars) holds, provided that bar is at or after the chart bar that made BullTarget and no earlier close since then exceeded that low[2]
Long: first bar at or after BullTapped becomes true where the last three AlternatingPivots are low, high, low, the middle high is below BullTarget, and a close above the middle high occurred at or after the later of the last low's bar and the bar BullTapped became true
Short: BearTapped AND NOT BearTapped[1]
Short: first bar at or after BearTapped becomes true where BearishFVG(chart bars) holds
Short: first bar at or after BearTapped becomes true where close < high[2] evaluated at the latest chart bar where BullishFVG(chart bars) holds, provided that bar is at or after the chart bar that made BearTarget and no earlier close since then fell below that high[2]
Short: first bar at or after BearTapped becomes true where the last three AlternatingPivots are high, low, high, the middle low is above BearTarget, and a close below the middle low occurred at or after the later of the last high's bar and the bar BearTapped became true
Exit: Long, high >= BullTarget
Exit: Long, close(T1, last completed bar) < high[2] of T1 bars evaluated at the most recent chart bar where BullishFVG(T1, last completed bar) holds
Exit: Short, low <= BearTarget
Exit: Short, close(T1, last completed bar) > low[2] of T1 bars evaluated at the most recent chart bar where BearishFVG(T1, last completed bar) holds