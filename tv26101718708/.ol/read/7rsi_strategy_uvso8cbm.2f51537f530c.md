Calculation: Bot reference = (open + high + low + close) / 4 from the configured bot timeframe; use the configured timeframe relative to the chart timeframe, with its current forming bar in real time and last completed bar historically.
Calculation: Long grid limits = bot reference and successive configured equal-percentage steps below it.
Calculation: Short grid limits = bot reference and successive configured equal-percentage steps above it.
Long: Position is flat AND long mode is selected AND each of the seven RSIs is below its respective configured threshold; place buy limit orders at the long grid limits.
Short: Position is flat AND short mode is selected AND each of the seven RSIs is above its respective configured threshold; place sell limit orders at the short grid limits.
Exit: long, high >= average entry price × (1 + configured take-profit percentage)
Exit: short, low <= average entry price × (1 − configured take-profit percentage)