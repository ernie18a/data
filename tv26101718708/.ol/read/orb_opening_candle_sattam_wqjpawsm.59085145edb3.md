Calculation: Opening range high/low = highest high and lowest low during the first session-duration window, using completed bars aggregated from the backtest data.
Calculation: Stop price = opening-range midpoint or opposite edge, according to the selected stop placement.
Calculation: Target 2 = entry price plus or minus the selected multiple of the absolute distance between entry price and stop price, in the position direction.
Long: opening range is complete and session is active AND (first close above opening-range high for the day OR, after a prior close above the high, a later bar touches the high and closes above it; only the first such retest)
Short: opening range is complete and session is active AND (first close below opening-range low for the day OR, after a prior close below the low, a later bar touches the low and closes below it; only the first such retest)
Exit: Long, low <= stop price OR high >= Target 2 OR session ends
Exit: Short, high >= stop price OR low <= Target 2 OR session ends