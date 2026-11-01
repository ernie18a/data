Calculation: Control bar = a forming higher-timeframe bar aggregated from chart bars.
Calculation: Entry distance = a configured positive price distance, the mean absolute open-to-close body, or half the mean high-to-low range of completed control bars after the start of the preceding calendar day, excluding the bar containing that start.
Calculation: Entry window = current time is within the configured trading hours, before the configured end-of-session cutoff, outside excluded weekdays and hours, and within the configured elapsed time from the start of the control bar.
Calculation: Long reference price = either the low of the last completed lower-timeframe bar or the low of the forming control bar.
Calculation: Short reference price = either the forming chart bar open or close, the last completed chart bar close, the forming lower-timeframe bar open, the last completed lower-timeframe bar high, or the forming control bar high.
Long: Entry window is true AND control bar high - control bar open <= tolerance AND entry distance <= control bar open - long reference price <= 2 * entry distance.
Short: Entry window is true AND control bar high - control bar open > tolerance AND control bar open - control bar low <= tolerance AND entry distance <= short reference price - control bar open <= 2 * entry distance.
Exit: long, current price >= entry price + take-profit distance OR current price <= entry price - stop-loss distance.
Exit: long, current price >= the open of the control bar at an index equal to the number of completed higher-timeframe age bars since entry.
Exit: long, current price < entry price - 2 * max(mean completed control-bar range, entry distance at entry) AND entry is in the current higher-timeframe age bar.
Exit: long OR short, the number of completed higher-timeframe age bars since entry >= the configured positive lifetime.