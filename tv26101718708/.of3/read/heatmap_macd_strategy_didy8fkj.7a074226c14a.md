Calculation: H1 = MACD histogram(price source, fast lookback, slow lookback, signal lookback) calculated on T1 bars and mapped to chart bars using the current, potentially forming, T1 bar
Calculation: H2 = MACD histogram(price source, fast lookback, slow lookback, signal lookback) calculated on T2 bars and mapped to chart bars using the current, potentially forming, T2 bar
Calculation: H3 = MACD histogram(price source, fast lookback, slow lookback, signal lookback) calculated on T3 bars and mapped to chart bars using the current, potentially forming, T3 bar
Calculation: H4 = MACD histogram(price source, fast lookback, slow lookback, signal lookback) calculated on T4 bars and mapped to chart bars using the current, potentially forming, T4 bar
Calculation: H5 = MACD histogram(price source, fast lookback, slow lookback, signal lookback) calculated on T5 bars and mapped to chart bars using the current, potentially forming, T5 bar
Calculation: Long stop level = maximum of entry price minus stop-loss distance, highest high since entry minus trailing-stop distance when trailing stop is enabled, and entry price plus breakeven offset after close-based profit has reached the breakeven activation threshold when breakeven mode is enabled
Calculation: Short stop level = minimum of entry price plus stop-loss distance, lowest low since entry plus trailing-stop distance when trailing stop is enabled, and entry price minus breakeven offset after close-based profit has reached the breakeven activation threshold when breakeven mode is enabled
Long: (H1 > 0 AND H1[1] < 0) OR (H2 > 0 AND H2[1] < 0) OR (H3 > 0 AND H3[1] < 0) OR (H4 > 0 AND H4[1] < 0) OR (H5 > 0 AND H5[1] < 0)
Short: (H1 < 0 AND H1[1] > 0) OR (H2 < 0 AND H2[1] > 0) OR (H3 < 0 AND H3[1] > 0) OR (H4 < 0 AND H4[1] > 0) OR (H5 < 0 AND H5[1] > 0)
Long: H1 > 0 AND H2 > 0 AND H3 > 0 AND H4 > 0 AND H5 > 0 AND (H1[1] <= 0 OR H2[1] <= 0 OR H3[1] <= 0 OR H4[1] <= 0 OR H5[1] <= 0) AND chart bar confirmed
Short: H1 < 0 AND H2 < 0 AND H3 < 0 AND H4 < 0 AND H5 < 0 AND (H1[1] >= 0 OR H2[1] >= 0 OR H3[1] >= 0 OR H4[1] >= 0 OR H5[1] >= 0) AND chart bar confirmed
Exit: Long, H1[1] > 0 AND H2[1] > 0 AND H3[1] > 0 AND H4[1] > 0 AND H5[1] > 0 AND (H1 <= 0 OR H2 <= 0 OR H3 <= 0 OR H4 <= 0 OR H5 <= 0) AND (H1 >= 0 OR H2 >= 0 OR H3 >= 0 OR H4 >= 0 OR H5 >= 0)
Exit: Short, H1[1] < 0 AND H2[1] < 0 AND H3[1] < 0 AND H4[1] < 0 AND H5[1] < 0 AND (H1 >= 0 OR H2 >= 0 OR H3 >= 0 OR H4 >= 0 OR H5 >= 0) AND (H1 <= 0 OR H2 <= 0 OR H3 <= 0 OR H4 <= 0 OR H5 <= 0)
Exit: Long, stop-loss mode enabled AND low <= long stop level
Exit: Short, stop-loss mode enabled AND high >= short stop level
Exit: Long, high >= entry price + take-profit 1 distance
Exit: Long, high >= entry price + take-profit 2 distance
Exit: Short, low <= entry price - take-profit 1 distance
Exit: Short, low <= entry price - take-profit 2 distance