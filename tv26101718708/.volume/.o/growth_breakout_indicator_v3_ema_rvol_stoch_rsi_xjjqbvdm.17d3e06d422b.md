Calculation: 52-week high = highest high over a long lookback, including the current bar
Calculation: Prior breakout high = highest high over a shorter lookback, excluding the current bar
Calculation: Relative volume = current volume / simple moving average of volume over a lookback
Calculation: Stoch RSI K = smoothed position of RSI within its recent low-to-high range; Stoch RSI D = smoothed Stoch RSI K
Long: absolute(close - fast EMA) / close * 100 <= consolidation threshold AND close >= 52-week high * (1 - proximity threshold / 100) AND close > prior breakout high AND relative volume >= volume threshold AND (fast EMA crosses above slow EMA OR close > fast EMA) AND Stoch RSI K > Stoch RSI D AND Stoch RSI K < overbought threshold
Exit: Long, close crosses below slow EMA