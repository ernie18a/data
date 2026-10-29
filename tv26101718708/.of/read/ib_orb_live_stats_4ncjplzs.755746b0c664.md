Calculation: Window midpoint = (window high + window low) / 2
Calculation: First extreme = whether the window high or low was reached first, determined from completed bars of a lower timeframe than the chart timeframe
Calculation: First range break = whether price first reached at least the window high or at most the window low after the window closed, determined from lower-timeframe bars; if both occur in the same bar, count the high first
Long: (IB or ORB first extreme is the low AND its close is at or above its midpoint) OR (after an IB or ORB window closes, its high is reached before its low)
Short: (IB or ORB first extreme is the high AND its close is below its midpoint) OR (after an IB or ORB window closes, its low is reached before its high)