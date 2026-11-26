Calculation: opening range high = high of the session's first completed T1 bar, read on chart bars
Calculation: opening range low = low of the session's first completed T1 bar, read on chart bars
Calculation: internal level(ratio) = opening range low + (opening range high - opening range low) * ratio
Calculation: OTE zone = [internal level(OTE lower ratio), internal level(OTE upper ratio)]
Long: On a chart bar, after price crosses above opening range high, the bar's low <= internal level(internal retracement ratio 1) <= the bar's high OR the bar's low <= internal level(internal retracement ratio 2) <= the bar's high
Short: On a chart bar, after price crosses below opening range low, the bar's low <= internal level(internal retracement ratio 1) <= the bar's high OR the bar's low <= internal level(internal retracement ratio 2) <= the bar's high
Long: On a chart bar, after price crosses below opening range low, the bar's high >= OTE lower boundary AND the bar's low <= OTE upper boundary
Short: On a chart bar, after price crosses above opening range high, the bar's high >= OTE lower boundary AND the bar's low <= OTE upper boundary