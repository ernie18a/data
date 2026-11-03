Calculation: Adaptive channel = SMA of highs and SMA of lows over a length equal to the rounded base length multiplied by (1 + (1 - ATR / longer-lookback SMA of ATR) × adaptive factor), bounded below by a minimum length; use an ATR ratio of 1 when its SMA is not positive.
Calculation: Channel state = initially 0; set to 1 when close is above the adaptive high SMA, otherwise set to -1 when close is below the adaptive low SMA, otherwise retain the prior state.
Calculation: Value area = divide the range from the rolling lowest low to the rolling highest high into equal price rows. Distribute each bar's volume equally among the rows from its low row through its high row, inclusive. Start at the highest-volume row, choosing the lowest row on a tie, and add the adjacent row with greater volume until the selected volume reaches the target fraction of total volume; choose the upper row on a tie. The value area bounds are the outer edges of the selected rows.
Long: Channel state = 1
Short: Channel state = -1
Long: A confirmed pivot high is greater than the preceding confirmed pivot high OR a confirmed pivot low is greater than the preceding confirmed pivot low
Short: A confirmed pivot high is less than the preceding confirmed pivot high OR a confirmed pivot low is less than the preceding confirmed pivot low
Long: The latest confirmed pivot high is greater than the preceding pivot high AND the latest confirmed pivot low is greater than the preceding pivot low
Short: The latest confirmed pivot high is less than the preceding pivot high AND the latest confirmed pivot low is less than the preceding pivot low
Long: Close > upper value area bound
Short: Close < lower value area bound