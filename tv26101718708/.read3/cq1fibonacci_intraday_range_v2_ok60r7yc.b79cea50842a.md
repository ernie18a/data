Calculation: green-high score = rounded percentage of chart bars with close[1] > open[1] and high >= high[1] among chart bars with close[1] > open[1], updated only when both conditions hold and otherwise retaining its previous value, initially 0
Calculation: green-low score = rounded percentage of chart bars with close[1] > open[1] and low <= low[1] among chart bars with close[1] > open[1], updated only when both conditions hold and otherwise retaining its previous value, initially 0
Calculation: red-high score = rounded percentage of chart bars with close[1] < open[1] and high >= high[1] among chart bars with close[1] < open[1], updated only when both conditions hold and otherwise retaining its previous value, initially 0
Calculation: red-low score = rounded percentage of chart bars with close[1] < open[1] and low <= low[1] among chart bars with close[1] < open[1], updated only when both conditions hold and otherwise retaining its previous value, initially 0
Long: close >= open(T1, current forming bar), sampled on chart bars
Short: close < open(T1, current forming bar), sampled on chart bars
Long: close[1] > open[1] AND green-high score >= green-low score
Short: close[1] > open[1] AND green-high score < green-low score
Long: close[1] <= open[1] AND red-high score >= red-low score
Short: close[1] <= open[1] AND red-high score < red-low score