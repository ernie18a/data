Calculation: Lowest prior-five high = the lowest high among the five most recent completed bars of a timeframe higher than the chart timeframe
Calculation: Second-lowest prior-five high = the second-lowest high among those same five completed higher-timeframe bars
Calculation: Highest prior-five low = the highest low among those same five completed higher-timeframe bars
Calculation: Second-highest prior-five low = the second-highest low among those same five completed higher-timeframe bars
Long: position is flat AND close >= lowest prior-five high × (1 + entry buffer) AND bar hour <= configured entry cutoff hour
Short: position is flat AND close <= highest prior-five low × (1 − entry buffer) AND bar hour <= configured entry cutoff hour
Exit: long, close < second-lowest prior-five high OR close > lowest prior-five high × (1 + entry buffer + profit target) OR bar hour = configured forced-exit hour
Exit: short, close > second-highest prior-five low OR close < highest prior-five low × (1 − entry buffer − profit target) OR bar hour = configured forced-exit hour