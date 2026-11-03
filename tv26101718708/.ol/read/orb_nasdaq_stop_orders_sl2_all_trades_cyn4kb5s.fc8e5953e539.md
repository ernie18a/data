Calculation: Opening range high = highest high during the opening range session
Calculation: Opening range low = lowest low during the opening range session
Calculation: Opening range midpoint = (opening range high + opening range low) / 2
Calculation: Long stop price = opening range midpoint
Calculation: Long target price = entry price + (entry price − opening range midpoint) × take-profit risk/reward parameter
Calculation: Short stop price = opening range midpoint
Calculation: Short target price = entry price − (opening range midpoint − entry price) × take-profit risk/reward parameter
Long: Opening range session has ended AND current bar is in the entry session AND no trade has been taken today AND no position is active AND high ≥ opening range high
Short: Opening range session has ended AND current bar is in the entry session AND no trade has been taken today AND no position is active AND NOT (high ≥ opening range high) AND low ≤ opening range low
Exit: Long, current bar is after the entry bar AND (high ≥ long target price OR (high < long target price AND low ≤ long stop price) OR (high < long target price AND low > long stop price AND bar close time ≥ configured stop time))
Exit: Short, current bar is after the entry bar AND (low ≤ short target price OR (low > short target price AND high ≥ short stop price) OR (low > short target price AND high < short stop price AND bar close time ≥ configured stop time))