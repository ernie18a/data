Calculation: Relative volume = current volume divided by its average over a shorter lookback
Calculation: EMA slope = short-term EMA of close minus its value several bars earlier
Calculation: Short-lookback low = lowest low over a shorter lookback of prior completed bars, excluding the current bar
Calculation: Short-lookback high = highest high over the same shorter lookback of prior completed bars, excluding the current bar
Calculation: Long-lookback low = lowest low over a longer lookback of prior completed bars, excluding the current bar
Calculation: Long-lookback high = highest high over the same longer lookback of prior completed bars, excluding the current bar
Long: (EMA slope > 0 AND close > short-term EMA AND close > open AND relative volume > a threshold AND RSI > a threshold AND MACD histogram > its previous value) OR low > high two bars earlier OR (low < long-lookback low AND close > long-lookback low AND close > open AND relative volume > a threshold) OR (low < short-lookback low AND close > open)
Short: (EMA slope < 0 AND close < short-term EMA AND close < open AND relative volume > a threshold AND RSI < a threshold AND MACD histogram < its previous value) OR high < low two bars earlier OR (high > long-lookback high AND close < long-lookback high AND close < open AND relative volume > a threshold) OR (high > short-lookback high AND close < open)