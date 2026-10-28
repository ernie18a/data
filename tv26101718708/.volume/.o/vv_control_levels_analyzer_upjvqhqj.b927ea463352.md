Calculation: Daily, weekly, and monthly POC = For each period, use its bars’ typical prices (high + low + close)/3 and volumes. Divide the period’s typical-price range into equal rows, assign each bar’s volume to the row containing its typical price, and use the midpoint of the row with the greatest accumulated volume. Use the last completed period.
Calculation: VWAP gate and deviation bands = For the selected daily, weekly, or monthly anchor period, calculate volume-weighted average typical price and its volume-weighted standard deviation from that period’s bars. Use the last completed period. The first upper and lower bands are one selected deviation multiplier above and below VWAP.
Calculation: Active POC = The selected daily, weekly, or monthly POC.
Calculation: Control count = Number of Daily POC, weekly POC, monthly POC, and VWAP gate levels below the current close.
Calculation: Near control = Current close is within the selected distance percentage of any Daily, weekly, or monthly POC, the VWAP gate, or its first upper or lower deviation band.
Long: Current close crosses above the VWAP gate AND (strong volume is not required OR current volume >= selected volume-ratio threshold)
Long: Current low <= first lower VWAP band AND current close > first lower VWAP band AND current close > current open
Long: Current close crosses above the first upper VWAP band
Long: Current close crosses above active POC
Long: Control count = 4 AND NOT near control
Long: Control count = 3 AND NOT near control
Long: Current close > VWAP gate AND (current close crosses above VWAP gate with valid volume OR current close crosses above active POC OR current close crosses above first upper VWAP band)
Long: Current low <= first lower VWAP band AND current close > first lower VWAP band AND current close > current open AND current close < VWAP gate
Short: Current close crosses below VWAP gate
Short: Current high >= first upper VWAP band AND current close < first upper VWAP band AND current close < current open
Short: Current close < first lower VWAP band AND previous close >= first lower VWAP band
Short: Current close crosses below active POC
Short: Control count = 1 AND NOT near control
Short: Control count = 0 AND NOT near control
Short: Current close < VWAP gate AND (current close < first lower VWAP band AND previous close >= first lower VWAP band OR current close crosses below VWAP gate OR current close crosses below active POC)
Exit: