Calculation: Relative volume = current volume / average volume over its lookback
Calculation: Breakout high = highest high over the lookback, excluding the current bar
Calculation: Breakdown low = lowest low over the lookback, excluding the current bar
Calculation: Strong bullish close = close is in the top quarter of the bar's high-low range
Calculation: Strong bearish close = close is in the bottom quarter of the bar's high-low range
Calculation: Long stop = lowest low over the stop lookback including the entry bar − ATR buffer
Calculation: Short stop = highest high over the stop lookback including the entry bar + ATR buffer
Calculation: Long target = entry price + (entry price − long stop) × reward/risk multiple
Calculation: Short target = entry price − (short stop − entry price) × reward/risk multiple
Long: Flat position AND confirmed bar AND bullish trend (close > 50-period SMA AND close > 200-period SMA AND close > 21-period EMA AND 10-period EMA > 21-period EMA AND 21-period EMA > its prior-bar value) AND bullish SuperTrend AND RSI > 50 AND RSI < 75 AND relative volume ≥ normal threshold AND ATR / close ≥ minimum threshold AND (close − 21-period EMA) / ATR ≤ maximum extension AND ((close > breakout high AND close > open) OR (low ≤ 10-period EMA AND low ≥ 21-period EMA − ATR × pullback allowance AND close > 10-period EMA AND close > 21-period EMA AND close > prior-bar high AND close > open)) AND this raw condition was false on the prior bar
Short: Flat position AND confirmed bar AND bearish trend (close < 50-period SMA AND close < 200-period SMA AND close < 21-period EMA AND 10-period EMA < 21-period EMA AND 21-period EMA < its prior-bar value) AND bearish SuperTrend AND RSI < 50 AND RSI > 25 AND relative volume ≥ normal threshold AND ATR / close ≥ minimum threshold AND (21-period EMA − close) / ATR ≤ maximum extension AND ((close < breakdown low AND close < open) OR (high ≥ 10-period EMA AND high ≤ 21-period EMA + ATR × pullback allowance AND close < 10-period EMA AND close < 21-period EMA AND close < prior-bar low AND close < open)) AND this raw condition was false on the prior bar
Exit: Long, confirmed bar after the entry bar AND (low ≤ long stop OR (high ≥ long target AND low > long stop))
Exit: Short, confirmed bar after the entry bar AND (high ≥ short stop OR (low ≤ short target AND high < short stop))