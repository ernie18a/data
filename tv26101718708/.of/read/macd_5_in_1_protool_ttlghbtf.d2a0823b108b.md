Calculation: MACD = shorter-lookback moving average of a selected price source minus longer-lookback moving average of the same source, using the same selectable SMA or EMA type; its signal line is an independently selectable SMA or EMA of MACD.
Calculation: Histogram = MACD minus its signal line.
Calculation: Close moving average = selectable SMA, EMA, RMA, WMA, VWMA, DEMA, or TEMA of close.
Calculation: Zone moving average = selectable SMA, EMA, RMA, WMA, or VWMA of high; when DEMA or TEMA is selected, use that moving average of close instead.
Calculation: Confirmed MACD pivot = a MACD pivot high or low with configurable left and right lookbacks, evaluated on the bar where the right lookback completes. Compare its MACD and corresponding price high or low with those at the preceding confirmed pivot of the same type. Pivot separation is the number of bars between their confirmation bars minus one.
Long: MACD crosses above its signal line.
Short: MACD crosses below its signal line.
Long: MACD > signal line OR histogram >= zero.
Short: MACD < signal line OR histogram < zero.
Long: A confirmed MACD pivot low is higher than the preceding MACD pivot low AND its corresponding price low is lower than the preceding corresponding price low AND pivot separation is within the inclusive configured range AND the current pivot MACD is below zero AND, if the zero-restriction option is enabled, the highest MACD over a lookback equal to the sum of the pivot left and right lookbacks plus a configured buffer is below zero.
Short: A confirmed MACD pivot high is lower than the preceding MACD pivot high AND its corresponding price high is higher than the preceding corresponding price high AND pivot separation is within the inclusive configured range AND the current pivot MACD is above zero AND, if the zero-restriction option is enabled, the lowest MACD over a lookback equal to the sum of the pivot left and right lookbacks plus a configured buffer is above zero.
Long: The crossover strategy is enabled AND bar time is within the configured start-inclusive, end-exclusive interval AND MACD crosses above its signal line.
Exit: long from the crossover strategy, bar time is within the configured interval AND MACD crosses below its signal line.
Long: The MACD threshold strategy is enabled AND bar time is within the configured interval AND MACD crosses above its signal line AND MACD < the configured threshold AND signal line < the configured threshold.
Exit: long from the MACD threshold strategy, bar time is within the configured interval AND MACD crosses below its signal line.
Long: The close moving-average strategy is enabled AND bar time is within the configured interval AND MACD crosses above its signal line AND close > its close moving average on the current bar or any of the configured preceding bars.
Exit: long from the close moving-average strategy, bar time is within the configured interval AND MACD crosses below its signal line AND ((the selected average is SMA, EMA, RMA, WMA, or VWMA AND (current close > current close moving average OR close < its close moving average on any of the configured preceding bars)) OR (the selected average is DEMA or TEMA AND close < its close moving average on the current bar or any of the configured preceding bars)).
Long: The zone strategy is enabled AND bar time is within the configured interval AND MACD crosses above its signal line AND close > its zone moving average on the current bar or any of the configured preceding bars.
Exit: long from the zone strategy, bar time is within the configured interval AND MACD crosses below its signal line AND close < its zone moving average on the current bar or any of the configured preceding bars.
Long: The RSI strategy is enabled AND bar time is within the configured interval AND MACD crosses above its signal line AND RSI of close > the configured entry threshold AND RSI of close < the configured no-entry threshold.
Exit: long from the RSI strategy, bar time is within the configured interval AND MACD crosses below its signal line.
Exit: long, bar time < the configured start time OR bar time >= the configured end time.