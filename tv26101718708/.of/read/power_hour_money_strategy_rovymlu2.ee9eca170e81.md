Calculation: long trail stop = running maximum, since the long entry, of close * (1 - trail percentage)
Calculation: short trail stop = running minimum, since the short entry, of close * (1 + trail percentage)
Long: bar datetime is within a fixed intraday trading session window AND, for each of four timeframes (ordered longest to shortest, each at or above the chart timeframe), chart close > open of that timeframe's bar that contains the current bar (the bar still forming)
Short: bar datetime is within a fixed intraday trading session window AND, for each of four timeframes (ordered longest to shortest, each at or above the chart timeframe), chart close <= open of that timeframe's bar that contains the current bar (the bar still forming)
Exit: long, low <= long trail stop as of the prior bar OR bar datetime time-of-day equals a fixed end-of-day time
Exit: short, high >= short trail stop as of the prior bar OR bar datetime time-of-day equals a fixed end-of-day time