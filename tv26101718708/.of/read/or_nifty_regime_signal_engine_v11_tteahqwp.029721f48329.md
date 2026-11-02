Calculation: Normalized bias = (close − EMA of close) / ATR; use 0 when ATR is not positive.
Calculation: Bias state = initially neutral; on each bar, if the previous state is neutral, change to bullish when normalized bias > the positive entry threshold or bearish when normalized bias < the negative entry threshold; if the previous state is bullish, change to neutral when normalized bias < the bullish exit threshold; if the previous state is bearish, change to neutral when normalized bias > the bearish exit threshold; otherwise retain the previous state. The bullish exit threshold is nonnegative and below the bullish entry threshold; the bearish exit threshold is nonpositive and above the bearish entry threshold.
Long: Bias state = bullish.
Short: Bias state = bearish.
Exit: long, previous bias state = bullish AND current bias state = neutral.
Exit: short, previous bias state = bearish AND current bias state = neutral.