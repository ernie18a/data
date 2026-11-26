Calculation: leading average at first band = selected leading moving average type(leading source, leading lookback)[first leading offset]
Calculation: leading average at second band = selected leading moving average type(leading source, leading lookback)[first leading offset + second leading offset]
Calculation: leading average at third band = selected leading moving average type(leading source, leading lookback)[first leading offset + third leading offset]
Calculation: lagging average = selected lagging moving average type(lagging source, lagging lookback)[lagging offset]
Long: the selected risk choice’s comparison is true, with choices ordered from most to least aggressive: leading source > leading average at first band OR leading source > leading average at second band OR leading source > leading average at third band OR lagging source > lagging average OR leading average at first band > lagging average
Short: the selected risk choice’s comparison is true, with choices ordered from most to least aggressive: leading source < leading average at first band OR leading source < leading average at second band OR leading source < leading average at third band OR lagging source < lagging average OR leading average at first band < lagging average
Long: indicator setting enabled AND selected long-entry comparison is true AND selected short-entry comparison was true on the previous bar
Short: indicator setting enabled AND selected short-entry comparison is true AND selected long-entry comparison was true on the previous bar
Exit: long, stop-loss setting enabled AND low <= entry price * (1 - stop-loss fraction)
Exit: short, stop-loss setting enabled AND high >= entry price * (1 + stop-loss fraction)