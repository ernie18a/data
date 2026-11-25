Calculation: ConfirmedProfile(T1, profile row count, value-area percentage, profile bar cap, delta calculation mode, poor-edge row count, poor-edge threshold, minimum price increment) = on chart bars grouped by T1 period, use at most the most recent profile bar cap bars of each completed period; profile high and low are the maximum high and minimum low of those bars; divide max(profile high - profile low, minimum price increment × profile row count) into equal rows; replace missing or nonpositive volume with 1; assign each bar's volume equally to every row touched by its low-to-high range; for bar-direction delta, assign all volume bullish if close > open, all bearish if close < open, and half to each on a tie; for range-position delta, assign bullish volume as volume × clamp((close - low) / max(high - low, minimum price increment), 0, 1) and the remainder bearish; distribute bullish and bearish volume equally across touched rows; POC is the midpoint of the lowest row with maximum total volume; value area starts at POC and adds the adjacent row with greater volume until it reaches the value-area percentage of total volume, choosing the upper row on ties; VAH and VAL are the outer boundaries of included rows; poor high and poor low are true when the respective top or bottom min(poor-edge row count, profile row count) rows' total volume divided by POC row volume × that row count is at least the poor-edge threshold; return these values and the bullish and bearish row and profile volume totals for the last completed T1 period; values are unavailable if fewer than two chart bars are available.
Long: bullish profile volume >= bearish profile volume in the last completed T1 profile
Short: bearish profile volume > bullish profile volume in the last completed T1 profile
Long: a row in the last completed T1 profile has bullish row volume / total row volume >= imbalance threshold
Short: a row in the last completed T1 profile has bearish row volume / total row volume >= imbalance threshold
Long: close > VAH of the last completed T1 profile
Short: close < VAL of the last completed T1 profile
Long: lowest(close, acceptance confirmation bars) > VAH of the last completed T1 profile AND close[acceptance confirmation bars] <= VAH of that profile
Short: highest(close, acceptance confirmation bars) < VAL of the last completed T1 profile AND close[acceptance confirmation bars] >= VAL of that profile
Short: high > VAH of the last completed T1 profile AND close < VAH of that profile AND close[1] <= VAH of that profile
Long: low < VAL of the last completed T1 profile AND close > VAL of that profile AND close[1] >= VAL of that profile
Short: high > VAH of the last completed T1 profile AND close < VAL of that profile
Long: low < VAL of the last completed T1 profile AND close > VAH of that profile
Long: close > POC of the last completed T1 profile AND close[1] <= POC of that profile
Short: close < POC of the last completed T1 profile AND close[1] >= POC of that profile
Long: poor high is true for the last completed T1 profile AND high >= its profile high
Short: poor low is true for the last completed T1 profile AND low <= its profile low
Long: POC of the last completed T1 profile > POC of the preceding completed T1 profile
Short: POC of the last completed T1 profile < POC of the preceding completed T1 profile