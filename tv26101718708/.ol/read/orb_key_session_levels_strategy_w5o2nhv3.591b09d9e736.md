Calculation: Opening-range high = highest high during the configured opening-range session
Calculation: Opening-range low = lowest low during the configured opening-range session
Calculation: Opening-range midpoint = (opening-range high + opening-range low) / 2
Calculation: Long stop = opening-range midpoint, opening-range low, or entry price minus the configured fixed distance, according to the selected stop method
Calculation: Short stop = opening-range midpoint, opening-range high, or entry price plus the configured fixed distance, according to the selected stop method
Calculation: Risk distance = absolute difference between entry price and stop price
Calculation: Long profit target = entry price + risk distance × configured reward-to-risk multiple
Calculation: Short profit target = entry price − risk distance × configured reward-to-risk multiple
Long: Opening range is complete AND no entry signal has fired that day AND (breakout mode AND close crosses above opening-range high OR retest mode AND a prior close crossed above opening-range high, the retest has not timed out, and (low ≤ opening-range high in retest-zone mode OR low ≤ opening-range midpoint in retest-midpoint mode) AND close > opening-range high)
Short: Opening range is complete AND no entry signal has fired that day AND (breakout mode AND close crosses below opening-range low OR retest mode AND a prior close crossed below opening-range low, the retest has not timed out, and (high ≥ opening-range low in retest-zone mode OR high ≥ opening-range midpoint in retest-midpoint mode) AND close < opening-range low)
Exit: long, low ≤ long stop OR high ≥ any configured long profit target
Exit: short, high ≥ short stop OR low ≤ any configured short profit target