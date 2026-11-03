Calculation: Anchor price = selected price source
Calculation: Long stop candidate = selected method: anchor price − ATR × multiplier (ATR method); highest high over lookback − ATR × multiplier (Chandelier); lowest low over lookback (Donchian); anchor price − standard deviation of anchor price over lookback × multiplier (StdDev); or anchor price × (1 − percentage / 100) (Fixed %)
Calculation: Short stop candidate = selected method: anchor price + ATR × multiplier (ATR method); lowest low over lookback + ATR × multiplier (Chandelier); highest high over lookback (Donchian); anchor price + standard deviation of anchor price over lookback × multiplier (StdDev); or anchor price × (1 + percentage / 100) (Fixed %)
Calculation: ATR = average true range over its lookback; optionally use the last completed bar of a higher timeframe
Calculation: Long trailing stop = if prior close > prior long trailing stop, the greater of the long stop candidate and prior long trailing stop; otherwise the long stop candidate
Calculation: Short trailing stop = if prior close < prior short trailing stop, the lesser of the short stop candidate and prior short trailing stop; otherwise the short stop candidate
Calculation: Trend = 1 if close > prior short trailing stop; −1 if close < prior long trailing stop; otherwise prior trend (initialize to 1)
Calculation: Active stop = long trailing stop when trend is 1; short trailing stop when trend is −1
Long: trend = 1 AND prior trend = −1
Short: trend = −1 AND prior trend = 1
Exit: Long, close < active stop AND prior close ≥ prior active stop
Exit: Short, close > active stop AND prior close ≤ prior active stop