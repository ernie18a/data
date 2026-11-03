Calculation: Range high and range low = the highest high and lowest low of completed bars whose opening times are within the configured daily range interval, including its start and excluding its end; use a lower timeframe than the chart timeframe, or the chart timeframe if it is already the finest available timeframe.
Calculation: Long entry level = range high + entry offset.
Calculation: Short entry level = range low − entry offset.
Calculation: Long stop = range low − stop offset.
Calculation: Short stop = range high + stop offset.
Long: Current day is enabled AND time is at or after range end and before cancellation time AND range width is within the enabled minimum and maximum limits AND price at order placement is below the long entry level AND high reaches the long entry level AND no entry has occurred from the day's order set.
Short: Current day is enabled AND time is at or after range end and before cancellation time AND range width is within the enabled minimum and maximum limits AND price at order placement is above the short entry level AND low reaches the short entry level AND no entry has occurred from the day's order set.
Exit: long, low <= long stop OR high >= long entry level + risk-reward multiplier × (long entry level − long stop) OR enabled close time is reached.
Exit: short, high >= short stop OR low <= short entry level − risk-reward multiplier × (short stop − short entry level) OR enabled close time is reached.