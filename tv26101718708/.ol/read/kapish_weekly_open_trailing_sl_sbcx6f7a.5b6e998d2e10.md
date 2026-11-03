Calculation: Weekly open = open of the higher-timeframe weekly bar that is still forming
Calculation: Long initial stop = lowest low of the signal bar and its previous two bars
Calculation: Short initial stop = highest high of the signal bar and its previous two bars
Calculation: Long target 1 = signal-bar close + target 1 distance; long target 2 = signal-bar close + target 2 distance
Calculation: Short target 1 = signal-bar close − target 1 distance; short target 2 = signal-bar close − target 2 distance
Calculation: Long trailing stop = highest high since activation − trailing offset in ticks × minimum tick size; activation level = entry price + activation distance in ticks × minimum tick size
Calculation: Short trailing stop = lowest low since activation + trailing offset in ticks × minimum tick size; activation level = entry price − activation distance in ticks × minimum tick size
Long: position is flat AND close[2] > weekly open[2] + buffer AND close[3] <= weekly open[3] + buffer AND close > weekly open
Short: position is flat AND close[2] < weekly open[2] − buffer AND close[3] >= weekly open[3] − buffer AND close < weekly open
Exit: Long, low <= long initial stop OR high >= long target 1 OR high >= long target 2 OR high >= long activation level AND low <= long trailing stop
Exit: Short, high >= short initial stop OR low <= short target 1 OR low <= short target 2 OR low <= short activation level AND high >= short trailing stop