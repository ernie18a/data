Calculation: Opening-range high = maximum chart-bar high during the selected session's opening interval, using the selected session and timezone parameters; with custom-session mode disabled, use chart bars from the first chart-session bar until the selected fallback timeframe T1 changes
Calculation: Opening-range low = minimum chart-bar low during the selected session's opening interval, using the selected session and timezone parameters; with custom-session mode disabled, use chart bars from the first chart-session bar until the selected fallback timeframe T1 changes
Calculation: Opening-range range = opening-range high - opening-range low
Calculation: Long breakout level = opening-range high + entry-buffer parameter
Calculation: Short breakout level = opening-range low - entry-buffer parameter
Calculation: Initial long stop = min(opening-range low + (1 - stop-fraction parameter) * opening-range range - stop-buffer parameter, long breakout level - instrument minimum price increment)
Calculation: Initial short stop = max(opening-range high - (1 - stop-fraction parameter) * opening-range range + stop-buffer parameter, short breakout level + instrument minimum price increment)
Calculation: Long stop = max(initial long stop, fill price) after the break-even option is enabled and high >= fill price + abs(fill price - initial long stop); otherwise initial long stop
Calculation: Short stop = min(initial short stop, fill price) after the break-even option is enabled and low <= fill price - abs(fill price - initial short stop); otherwise initial short stop
Calculation: Long target = long breakout level + abs(long breakout level - initial long stop) * reward-to-risk parameter
Calculation: Short target = short breakout level - abs(short breakout level - initial short stop) * reward-to-risk parameter
Long: Opening range is complete and nonzero AND position is flat AND no earlier long or short breakout occurred in this session AND current chart-bar weekday is Monday through Friday and its corresponding weekday parameter is enabled AND (first-window restriction is disabled OR chart-bar time <= session start + first-window duration parameter) AND close crosses above long breakout level
Short: Opening range is complete and nonzero AND position is flat AND no earlier long or short breakout occurred in this session AND current chart-bar weekday is Monday through Friday and its corresponding weekday parameter is enabled AND (first-window restriction is disabled OR chart-bar time <= session start + first-window duration parameter) AND close crosses below short breakout level
Exit: Long, low <= long stop OR high >= long target
Exit: Short, high >= short stop OR low <= short target