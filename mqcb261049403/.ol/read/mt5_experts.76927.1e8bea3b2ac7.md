Calculation: Range high = highest high of the configured number of previous completed chart bars when the range is set
Calculation: Range low = lowest low of the configured number of previous completed chart bars when the range is set
Calculation: Initial risk distance = absolute difference between entry price and the opposite range edge
Calculation: R = favorable price movement from entry divided by initial risk distance
Long: During the configured daily entry window, before any successful entry that day, range low < range high AND range width >= minimum ATR multiple × ATR AND range width <= maximum ATR multiple × ATR AND (configured touch mode: current bar high >= range high OR configured close mode: last completed chart bar close > range high)
Short: During the configured daily entry window, before any successful entry that day, range low < range high AND range width >= minimum ATR multiple × ATR AND range width <= maximum ATR multiple × ATR AND (configured touch mode: current bar low <= range low OR configured close mode: last completed chart bar close < range low)
Exit: Long, current price <= active stop OR current price >= fixed target at configured R multiple OR time >= configured end time
Exit: Short, current price >= active stop OR current price <= fixed target at configured R multiple OR time >= configured end time