Calculation: Upper and lower channel = volume-weighted moving averages of high and low, respectively, over the same lookback; add the same price offset and round each to the nearest price increment. Compare each bar with the channel calculated a configurable number of bars earlier.
Long: Close > upper channel.
Short: Close < lower channel.
Long: On the higher timeframe, the last completed bar's close > its upper channel AND the preceding bar's close <= its upper channel.
Short: On the higher timeframe, the last completed bar's close < its lower channel AND the preceding bar's close >= its lower channel.
Exit: long, the last completed higher-timeframe bar's close < its lower channel OR low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance.
Exit: short, the last completed higher-timeframe bar's close > its upper channel OR high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance.