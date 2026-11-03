Calculation: RVOL = current-bar volume divided by the simple moving average of volume over a longer lookback
Calculation: EMA slope = short-term EMA minus that EMA from several bars earlier
Long: EMA slope > 0 AND close > short-term EMA AND close > open AND RVOL > RVOL threshold AND RSI > upper momentum threshold AND MACD histogram > prior-bar MACD histogram
Short: EMA slope < 0 AND close < short-term EMA AND close < open AND RVOL > RVOL threshold AND RSI < lower momentum threshold AND MACD histogram < prior-bar MACD histogram
Long: low < lowest low of the preceding lookback bars AND close > that level AND close > open AND RVOL > RVOL threshold
Short: high > highest high of the preceding lookback bars AND close < that level AND close < open AND RVOL > RVOL threshold
Long: low < lowest low of the preceding lookback bars AND close > open
Short: high > highest high of the preceding lookback bars AND close < open
Long: low > high from two bars earlier
Short: high < low from two bars earlier