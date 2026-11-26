Calculation: session range high = maximum high of chart bars in the configured New York session (start-hour parameter, end-hour parameter)
Calculation: session range low = minimum low of chart bars in the configured New York session (start-hour parameter, end-hour parameter)
Long: after the session range is ready, chart-bar close < session range low
Short: after the session range is ready, chart-bar close > session range high
Long: after a chart-bar close below the ready session range low, chart-bar close > high of the most recent earlier chart bar with close < open
Short: after a chart-bar close above the ready session range high, chart-bar close < low of the most recent earlier chart bar with close > open
Long: after the ready session range has been swept below and a later chart-bar close is above the high of the most recent earlier bearish chart bar, T1 close of the still-forming bar, sampled on chart bars, > T1 open of the still-forming bar, sampled on chart bars
Short: after the ready session range has been swept above and a later chart-bar close is below the low of the most recent earlier bullish chart bar, T1 close of the still-forming bar, sampled on chart bars, < T1 open of the still-forming bar, sampled on chart bars