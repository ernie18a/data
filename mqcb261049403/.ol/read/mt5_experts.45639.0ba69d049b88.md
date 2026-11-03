Calculation: Rectangle high = highest high among the last N chart-timeframe bars, including the forming bar
Calculation: Rectangle low = low of the chart-timeframe bar whose high is lowest among the last N bars, including the forming bar
Calculation: Rectangle range percentage = (Rectangle high − Rectangle low) / Rectangle high × 100
Calculation: Daily losing-deal count = number of losing completed deals today for this symbol and strategy
Long: Rectangle range percentage < range threshold AND EMA is between Rectangle low and Rectangle high AND current time is after the start time and before the end time AND EMA < SMA AND bid < EMA AND daily losing-deal count < daily loss limit AND no position is open
Short: Rectangle range percentage < range threshold AND EMA is between Rectangle low and Rectangle high AND current time is after the start time and before the end time AND EMA > SMA AND ask > EMA AND daily losing-deal count < daily loss limit AND no position is open
Exit: Long, low ≤ entry price − stop distance OR high ≥ entry price + target distance OR time-based closing is enabled AND current time ≥ closing time
Exit: Short, high ≥ entry price + stop distance OR low ≤ entry price − target distance OR time-based closing is enabled AND current time ≥ closing time