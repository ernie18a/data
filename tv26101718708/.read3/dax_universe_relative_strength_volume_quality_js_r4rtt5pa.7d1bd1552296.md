Calculation: Weighted momentum(src) = weighted mean of src/src[n] across four separately weighted lookbacks (recent, medium, long, and very long), excluding unavailable terms and normalizing by the weights of available terms
Calculation: Relative strength = (Weighted momentum(stock close) / mean Weighted momentum(available benchmark closes) - 1) * 100
Calculation: High-volume down-day count = sum(close < close[1] AND (1 - close / close[1]) * 100 >= minimum loss AND volume > SMA(volume, volume lookback) * volume factor, over the down-day lookback)
Long: Relative strength crosses above 0
Short: Relative strength crosses below 0
Long: Relative strength crosses above SMA(relative strength, smoothing lookback)
Short: Relative strength crosses below SMA(relative strength, smoothing lookback)
Long: Relative strength crosses above the strong-strength threshold
Short: Relative strength crosses below the strong-strength threshold
Long: Relative strength is ready AND relative strength >= strong-strength threshold AND high-volume down-day count <= allowed count AND NOT (high-volume down-day count = allowed count AND allowed count > 0) AND NOT (the same condition was true on the prior bar)
Long: high-volume down-day count <= allowed count AND (0 < relative strength AND relative strength < strong-strength threshold OR relative strength < 0 AND SMA(relative strength, smoothing lookback) > SMA(relative strength, smoothing lookback)[1] OR (relative strength >= strong-strength threshold AND high-volume down-day count = allowed count AND allowed count > 0)) AND NOT (the same condition was true on the prior bar)
Calculation: weighted momentum = weighted average of price divided by price at four separately parameterized lookback periods, using separate weights for each period and renormalizing over available periods
Calculation: relative strength = 100 × (traded instrument weighted momentum ÷ arithmetic mean of available weighted momentums of the DAX, MDAX, SDAX, and TecDAX index closes − 1)
Calculation: high-volume down-day count = number of bars in the parameterized lookback where the traded instrument closes below its prior close by at least the parameterized percentage and volume exceeds its volume SMA at the parameterized length multiplied by the parameterized factor
Long: relative strength crosses above zero OR relative strength crosses above its SMA at the parameterized smoothing length OR relative strength crosses above the parameterized strength threshold OR relative strength, its SMA, and the prior SMA are available AND relative strength > 0 AND high-volume down-day count ≤ the parameterized maximum
Short: relative strength crosses below zero OR relative strength crosses below its SMA at the parameterized smoothing length OR relative strength crosses below the parameterized strength threshold OR relative strength, its SMA, and the prior SMA are available AND relative strength < 0 AND high-volume down-day count ≤ the parameterized maximum