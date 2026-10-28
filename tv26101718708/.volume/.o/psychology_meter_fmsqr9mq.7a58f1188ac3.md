Calculation: Prior rolling high = highest high over a long-term lookback, excluding the current bar
Calculation: Relative volume = current volume / average volume over a shorter lookback of completed bars
Calculation: Candle close position = (close - low) / (high - low)
Calculation: Euphoria bar = up-close bar with relative volume above its high-volume threshold, RSI above its overbought threshold, and close more than a configured multiple of ATR above a short-term average close
Long: close > prior rolling high AND close > previous close AND relative volume above its breakout threshold
Long: previous bar is a panic bar AND previous bar's close position is above its configured threshold AND close > previous close
Short: close < previous close AND relative volume above its high-volume threshold AND RSI below its oversold threshold
Exit: long, low < low of the most recent euphoria bar