Calculation: Alligator lines = three moving averages of the selected price, using the same smoothing method and long, intermediate, and short periods; use the unshifted buffer values.
Calculation: Upper pattern = low > each Alligator line AND close < (high + low) / 2 AND high > the high of every bar in the preceding lookback.
Calculation: Lower pattern = high < each Alligator line AND close > (high + low) / 2 AND low < the low of every bar in the preceding lookback.
Long: Lower pattern = true OR Upper pattern = true when reversed-direction trading is selected.
Short: Upper pattern = true OR Lower pattern = true when reversed-direction trading is selected.
Exit: long, the most recent qualifying pattern is the Upper pattern in normal-direction trading OR the most recent qualifying pattern is the Lower pattern in reversed-direction trading.
Exit: short, the most recent qualifying pattern is the Lower pattern in normal-direction trading OR the most recent qualifying pattern is the Upper pattern in reversed-direction trading.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.