Calculation: Opening-range high = Highest(high of chart bars in the opening-range window)
Calculation: Opening-range low = Lowest(low of chart bars in the opening-range window)
Calculation: Opening-range midpoint = (Opening-range high + Opening-range low) / 2
Calculation: Long risk = entry price - Opening-range low
Calculation: Short risk = Opening-range high - entry price
Long: opening range is locked AND close > Opening-range high
Short: opening range is locked AND close < Opening-range low
Long: bar is in the entry window AND opening range is locked AND no position has closed today AND position is flat AND at least one close has been outside the opening range since it was locked AND the most recent such close is above Opening-range high AND low <= Opening-range midpoint
Short: bar is in the entry window AND opening range is locked AND no position has closed today AND position is flat AND at least one close has been outside the opening range since it was locked AND the most recent such close is below Opening-range low AND high >= Opening-range midpoint
Exit: long, the entry window ended OR low <= Opening-range low OR high >= entry price + first reward-risk multiple * Long risk OR high >= entry price + second reward-risk multiple * Long risk OR the first target has been reached since entry AND low <= entry price
Exit: short, the entry window ended OR high >= Opening-range high OR low <= entry price - first reward-risk multiple * Short risk OR low <= entry price - second reward-risk multiple * Short risk OR the first target has been reached since entry AND high >= entry price
The second reward-risk multiple is greater than the first reward-risk multiple.