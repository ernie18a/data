Calculation: Opening-session high = highest high during the initial session window, fixed after the window ends until the next session day
Calculation: Opening-session low = lowest low during the initial session window, fixed after the window ends until the next session day
Calculation: Range size = opening-session high − opening-session low
Long: range is fixed AND close > opening-session high
Short: range is fixed AND close < opening-session low
Calculation: Long stop = opening-session low, or signal-bar close − range size when dynamic stop mode is selected
Calculation: Long target = signal-bar close + (signal-bar close − long stop) × risk/reward
Calculation: Short stop = opening-session high, or signal-bar close + range size when dynamic stop mode is selected
Calculation: Short target = signal-bar close − (short stop − signal-bar close) × risk/reward
Exit: long, low ≤ long stop OR high ≥ long target
Exit: short, high ≥ short stop OR low ≤ short target