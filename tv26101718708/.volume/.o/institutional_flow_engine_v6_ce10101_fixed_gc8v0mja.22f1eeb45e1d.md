Calculation: Relative volume = current bar volume / average volume over a longer lookback
Calculation: Short-term EMA slope = current short-term EMA − its value several bars earlier
Calculation: Failed-break support = lowest low over a longer lookback of completed bars, excluding the current bar
Calculation: Failed-break resistance = highest high over a longer lookback of completed bars, excluding the current bar
Calculation: Sweep low = lowest low over a shorter lookback of completed bars, excluding the current bar
Calculation: Sweep high = highest high over a shorter lookback of completed bars, excluding the current bar
Long: short-term EMA slope > 0 AND close > short-term EMA AND close > open AND relative volume > threshold AND RSI > bullish threshold AND MACD histogram > its previous-bar value OR low > high two bars earlier OR low < failed-break support AND close > failed-break support AND relative volume > threshold OR low < sweep low AND close > open
Short: short-term EMA slope < 0 AND close < short-term EMA AND close < open AND relative volume > threshold AND RSI < bearish threshold AND MACD histogram < its previous-bar value OR high < low two bars earlier OR high > failed-break resistance AND close < failed-break resistance AND relative volume > threshold OR high > sweep high AND close < open