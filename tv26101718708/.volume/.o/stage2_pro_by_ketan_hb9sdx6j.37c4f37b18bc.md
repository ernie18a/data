Calculation: Weekly stage moving average = simple moving average of weekly closes, using the still-forming weekly bar
Calculation: Monthly moving average = simple moving average of monthly closes, using the still-forming monthly bar
Calculation: Weekly higher-high age = number of weekly bars since the latest bar whose high was at least the highest high of the preceding longer lookback of weekly bars
Long: Still-forming weekly close > weekly stage moving average AND still-forming weekly close > still-forming monthly moving average AND still-forming monthly RSI > its threshold AND weekly higher-high age <= the shorter hold window
Exit: Long, current candle high < still-forming monthly moving average