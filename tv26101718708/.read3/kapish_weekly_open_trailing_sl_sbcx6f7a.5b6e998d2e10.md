Long: On chart bars, close crossed above open(T1, still-forming bar) plus breakout buffer two chart bars ago AND current chart-bar close is above open(T1, still-forming bar).
Short: On chart bars, close crossed below open(T1, still-forming bar) minus breakout buffer two chart bars ago AND current chart-bar close is below open(T1, still-forming bar).
Calculation: Long initial stop = minimum of low, low[1], and low[2] on the long-signal chart bar
Calculation: Short initial stop = maximum of high, high[1], and high[2] on the short-signal chart bar
Calculation: Long target 1 = long-signal chart-bar close + target 1 distance
Calculation: Long target 2 = long-signal chart-bar close + target 2 distance
Calculation: Short target 1 = short-signal chart-bar close - target 1 distance
Calculation: Short target 2 = short-signal chart-bar close - target 2 distance
Exit: Long, chart-bar low <= long initial stop OR chart-bar high >= long target 1 OR chart-bar high >= long target 2 OR (after chart-bar high reaches entry price + trailing distance, chart-bar low <= highest high since activation - the same trailing distance)
Exit: Short, chart-bar high >= short initial stop OR chart-bar low <= short target 1 OR chart-bar low <= short target 2 OR (after chart-bar low reaches entry price - trailing distance, chart-bar high >= lowest low since activation + the same trailing distance)